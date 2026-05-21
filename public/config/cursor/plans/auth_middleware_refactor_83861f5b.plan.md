---
name: Auth middleware refactor
overview: Create a global TanStack Start middleware that catches `OrgApiError` 401 responses and redirects to `/login`, then remove all the duplicated 401 catch-and-redirect blocks from individual `createServerFn` handlers.
todos:
  - id: create-middleware
    content: Create `src/server/middleware.ts` with `authMiddleware` that catches OrgApiError 401 and redirects to /login
    status: completed
  - id: create-start
    content: Create `src/start.ts` to register authMiddleware as global requestMiddleware
    status: completed
  - id: simplify-bootstrap
    content: Remove 401 catch from `getAppBootstrapData` in `src/server/app-bootstrap.ts`
    status: completed
  - id: simplify-dashboard
    content: Remove 401 catch from `getDashboardData` in `src/routes/_authed/index.tsx`
    status: completed
  - id: simplify-campaigns
    content: Remove 401 catch blocks from `updateCampaign`, `getCampaignDetail`, `createCampaign` in `src/routes/_authed/campaigns/-campaigns.ts`
    status: completed
  - id: update-docs
    content: Add a short note to `docs/README.md` explaining that 401 handling is centralized in the global authMiddleware
    status: completed
isProject: false
---

# Auth Middleware Refactor

## Current State

Auth (401 -> redirect to `/login`) is checked in **5 separate catch blocks** across 3 files:

- [`src/server/app-bootstrap.ts`](src/server/app-bootstrap.ts) — `getAppBootstrapData` catches `OrgApiError` 401
- [`src/routes/_authed/index.tsx`](src/routes/_authed/index.tsx) — `getDashboardData` catches `OrgApiError` 401
- [`src/routes/_authed/campaigns/-campaigns.ts`](src/routes/_authed/campaigns/-campaigns.ts) — `updateCampaign`, `getCampaignDetail`, and `createCampaign` each catch `OrgApiError` 401

All follow the same pattern:

```typescript
catch (error) {
  if (error instanceof OrgApiError && error.status === 401) {
    throw redirect({ to: "/login" });
  }
  throw error;
}
```

## Approach

Use TanStack Start's **global request middleware** via `src/start.ts` (per the [middleware docs](https://tanstack.com/start/v0/docs/framework/react/guide/middleware)). A single `authMiddleware` wraps every server request, catches any `OrgApiError` with status 401, and throws `redirect({ to: "/login" })`. This eliminates all the per-function 401 catch blocks.

## Changes

### 1. Create `src/server/middleware.ts`

Define `authMiddleware` using `createMiddleware()`:

```typescript
import { redirect } from "@tanstack/react-router";
import { createMiddleware } from "@tanstack/react-start";
import { OrgApiError } from "./error";

export const authMiddleware = createMiddleware().server(async ({ next }) => {
  try {
    return await next();
  } catch (error) {
    if (error instanceof OrgApiError && error.status === 401) {
      throw redirect({ to: "/login" });
    }
    throw error;
  }
});
```

### 2. Create `src/start.ts`

Register `authMiddleware` as global request middleware:

```typescript
import { createStart } from "@tanstack/react-start";
import { authMiddleware } from "./server/middleware";

export const startInstance = createStart(() => {
  return {
    requestMiddleware: [authMiddleware],
  };
});
```

### 3. Simplify `src/server/app-bootstrap.ts`

Remove the `OrgApiError` 401 catch from `getAppBootstrapData`. Keep the `!appBootstrap -> redirect("/login")` check (that handles the "user not found" case — a 404 on `/users/me`, not a 401):

```typescript
export const getAppBootstrapData = createServerFn({ method: "GET" }).handler(
  async (): Promise<AppBootstrap> => {
    const appBootstrap = await fetchAppBootstrapData();
    if (!appBootstrap) {
      throw redirect({ to: "/login" });
    }
    return appBootstrap;
  },
);
```

### 4. Simplify `src/routes/_authed/index.tsx`

Remove both the `OrgApiError` 401 catch AND the `!bootstrap?.currentTenant` redirect from `getDashboardData`. The tenant check is dead code — the [`_authed.tsx`](src/routes/_authed.tsx) layout loader runs first and already redirects users without a tenant to `/workspace/new`, so `getDashboardData` is only reached when a user session is valid. Also note: `currentTenant` is always `null` today (no caller passes `tenantId` to `fetchAppBootstrapData`), which is further evidence the check was unreachable/incorrect.

```typescript
const getDashboardData = createServerFn({ method: "GET" }).handler(async () => {
  const bootstrap = await getAppBootstrapData();
  const campaigns = (await fetchCampaignsList()) ?? [];
  const simplified = campaigns.map((c) => ({ id: c.id, name: c.name }));

  return {
    campaigns: simplified,
    cards: {
      campaigns: simplified.length,
      payouts: 7,
      transactions: 428,
    },
  } satisfies DashboardPageData;
});
```

Remove the now-unused `OrgApiError`, `redirect` imports.

### 5. Simplify `src/routes/_authed/campaigns/-campaigns.ts`

Remove the `OrgApiError` 401 catch blocks from `updateCampaign`, `getCampaignDetail`, and `createCampaign`. Each still needs its try/catch for Rollbar logging and other error handling, just without the 401-specific branch:

- `updateCampaign` — remove `if (error instanceof OrgApiError && error.status === 401)` branch
- `getCampaignDetail` — remove `if (error instanceof OrgApiError && error.status === 401)` branch
- `createCampaign` — remove `if (error instanceof OrgApiError && error.status === 401)` branch

Clean up the `redirect` import if it becomes unused (only `notFound`/`isNotFound` remain from `@tanstack/react-router`).

### 6. Update `docs/README.md`

The only docs file is [`docs/README.md`](docs/README.md), which has an "Auth Flow (cross-app)" section. Per the "keep sparse" directive, add one short paragraph (not a new section) noting that **401 responses from the Org API are handled globally by `authMiddleware` (registered in `src/start.ts`)**, which redirects to `/login`. This behavior isn't obvious from any single server function since individual handlers no longer show auth-error handling.

Proposed addition at the end of the "Auth Flow (cross-app)" section:

> Server functions do not handle 401s individually. A global request middleware in `src/start.ts` catches any `OrgApiError` with status 401 and redirects the browser to `/login`.

## What stays the same

- [`src/routes/_authed.tsx`](src/routes/_authed.tsx) — the layout loader's `getAppBootstrapData()` call and workspace redirect logic are unchanged (no 401 catch there)
- [`src/routes/_login/auth.ts`](src/routes/_login/auth.ts) — `redirectIfAuthenticated` is inverse auth (redirect *away* from login if authenticated); unrelated to 401 handling
- [`src/routes/_authed/-tenants.ts`](src/routes/_authed/-tenants.ts) — `createTenant` has no 401 catch today; unchanged
- [`src/server/org-api.server.ts`](src/server/org-api.server.ts) — the API layer that throws `OrgApiError` is unchanged
- `fetchTenants` in `app-bootstrap.ts` — keeps its explicit 401 re-throw (prevents the `return []` fallback from swallowing auth errors)
