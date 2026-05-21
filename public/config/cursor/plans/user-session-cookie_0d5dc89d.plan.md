---
name: user-session-cookie
overview: Add a shared client/server user-session cookie holding selected tenant id and theme, with a server helper for loaders and a React hook for components. Auto-resolve the selected tenant to the most recent one when the cookie value is missing or invalid.
todos:
  - id: server_module
    content: Add src/server/user-session.server.ts wrapping useSession with the UserSession shape.
    status: completed
  - id: public_server_fns
    content: Add src/server/user-session.ts exporting getUserSession, updateUserSession, and resolveSelectedTenantId.
    status: completed
  - id: bootstrap_integration
    content: Wire resolveSelectedTenantId into getAppBootstrapData and drop the unused tenantId parameter.
    status: completed
  - id: root_loader
    content: Add a __root loader that returns getUserSession() so theme is available on every route.
    status: completed
  - id: client_hook
    content: Add src/hooks/use-user-session.ts exposing session + setTheme/setSelectedTenantId via useMutation.
    status: completed
  - id: header_wiring
    content: Update app-header.tsx minimally to read the current tenant via the new hook/loader data.
    status: completed
  - id: tests
    content: Unit test resolveSelectedTenantId (empty tenants, invalid id, valid id, max updated_at).
    status: completed
  - id: docs
    content: Add a 'User session cookie' section to apps/org-next/docs/README.md.
    status: completed
isProject: false
---

## Shape

Store a small `userSession` object in a single signed, `httpOnly` cookie (same pattern as the existing cookies in [src/server/session.server.ts](apps/org-next/src/server/session.server.ts)). The client never reads the cookie directly — it receives the current value through the root route loader and mutates it through a server function. A thin React hook (`useUserSession`) wraps the loader data + mutation so components treat it like ordinary state.

```ts
type UserSession = {
  selectedTenantId: number | null;
  theme: "light" | "dark" | "system";
};
```

- Defaults: `{ selectedTenantId: null, theme: "system" }`.
- `selectedTenantId` resolution (runs where we already fetch tenants, in `getAppBootstrapData`):
  1. Read from cookie. Valid if it matches a tenant id in the fetched `tenants` list.
  2. Otherwise, pick the tenant with the greatest `updated_at`, persist it to the cookie, and return that.
  3. If `tenants` is empty, keep `null` (allowed state).

## Key files

### New

- [src/server/user-session.server.ts](apps/org-next/src/server/user-session.server.ts) — wraps `useSession` (server-only) with a `UserSession` shape and signed, `httpOnly` cookie. Exports two server-only helpers used by the server functions below.

  ```ts
  import { createServerOnlyFn } from "@tanstack/react-start";
  import { useSession } from "@tanstack/react-start/server";
  import { env } from "@/env";

  export type UserSession = {
    selectedTenantId: number | null;
    theme: "light" | "dark" | "system";
  };

  const DEFAULTS: UserSession = { selectedTenantId: null, theme: "system" };

  export const useUserSessionStore = createServerOnlyFn(() =>
    useSession<Partial<UserSession>>({
      password: env.SESSION_SECRET,
      name: "userSession",
      cookie: {
        httpOnly: true,
        sameSite: "lax",
        secure: import.meta.env.MODE === "production",
        maxAge: 3600 * 24 * 365,
        path: "/",
      },
    }),
  );

  // read + merge with defaults, and update helpers
  ```

- [src/server/user-session.ts](apps/org-next/src/server/user-session.ts) — public-facing, used by loaders/route code:
  - `getUserSession` — `createServerFn` that reads the cookie and returns a fully-populated `UserSession`.
  - `updateUserSession` — `createServerFn` that takes a `Partial<UserSession>`, validates with zod, merges, writes the cookie, and returns the new value.
  - `resolveSelectedTenantId(tenants: Tenant[])` — server-only helper used by `getAppBootstrapData`: reads the cookie, validates the stored id against `tenants`, falls back to the tenant with max `updated_at`, persists the fallback, and returns the id (or `null` if no tenants).

- [src/hooks/use-user-session.ts](apps/org-next/src/hooks/use-user-session.ts) — React hook used by components:
  - Reads the current value from the root route loader via `getRouteApi("__root__").useLoaderData()` (or from `_authed` if we keep it there — see below).
  - Exposes `{ session, setSession, setTheme, setSelectedTenantId }` where the setters call `useMutation({ mutationFn: updateUserSession })` and invalidate the route on success so loaders see the new value.

### Modified

- [src/routes/__root.tsx](apps/org-next/src/routes/__root.tsx) — add a `loader` that calls `getUserSession()` and returns `{ userSession }`. This makes the session available on every route (including unauthenticated ones) so `theme` applies immediately after SSR.
- [src/server/app-bootstrap.ts](apps/org-next/src/server/app-bootstrap.ts) — after `fetchTenants`, call `resolveSelectedTenantId(tenants)` instead of the current unused `tenantId` argument and use the returned id to compute `currentTenant`. Replace:
  
  ```ts
  const currentTenant = tenantId
    ? (tenants.find((tenant) => tenant.id === tenantId) ?? null)
    : null;
  ```
  
  with a call to the new resolver. This is the single place that persists a fallback tenant id to the cookie.
- [src/components/app-header.tsx](apps/org-next/src/components/app-header.tsx) — replace the hard-coded `currentTenantName = "test"` with data from `useUserSession` + bootstrap loader data (future work: theme toggle wired to `setTheme`). Only the minimum wiring needed for this change.

## Flow

```mermaid
sequenceDiagram
  participant Browser
  participant Root as __root loader
  participant Authed as _authed loader
  participant Bootstrap as getAppBootstrapData
  participant Resolver as resolveSelectedTenantId
  participant Cookie as userSession cookie

  Browser->>Root: request
  Root->>Cookie: getUserSession()
  Cookie-->>Root: { theme, selectedTenantId }
  Root-->>Browser: loader data (userSession)
  Browser->>Authed: (authed route)
  Authed->>Bootstrap: getAppBootstrapData()
  Bootstrap->>Resolver: resolveSelectedTenantId(tenants)
  Resolver->>Cookie: read selectedTenantId
  alt missing or invalid
    Resolver->>Cookie: write most-recent tenant id
  end
  Resolver-->>Bootstrap: id | null
  Bootstrap-->>Authed: AppBootstrap (currentTenant)
  Authed-->>Browser: loader data
```

## Client usage

```ts
const { session, setTheme, setSelectedTenantId } = useUserSession();
// session.theme, session.selectedTenantId
await setTheme("dark");
```

## Server / loader usage

```ts
import { getUserSession } from "@/server/user-session";

export const Route = createFileRoute("/some/route")({
  loader: async () => {
    const session = await getUserSession();
    return { theme: session.theme };
  },
});
```

## Validation and tests

- Unit test `resolveSelectedTenantId` in `src/server/user-session.test.ts` covering: empty tenants, invalid stored id, valid stored id, picking max `updated_at`.
- `pnpm --filter org-next typecheck` and `pnpm --filter org-next check`.

## Docs

- Update [apps/org-next/docs/README.md](apps/org-next/docs/README.md): add a short "User session cookie" section under the existing "Tenant bootstrap" section pointing at `src/server/user-session.ts` and documenting the cookie name, defaults, and the fallback rule for `selectedTenantId`.