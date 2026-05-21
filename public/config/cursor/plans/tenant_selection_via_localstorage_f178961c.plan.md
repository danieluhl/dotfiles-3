---
name: Tenant selection via localStorage
overview: Manage selected tenant (and theme) entirely on the client in localStorage, reshape bootstrap data so getAppBootstrapData takes an explicit tenantId and returns { user, tenants, currentTenant }, keep all tenant-scoped data loading in TanStack loaders by opting the _authed subtree out of SSR, and have each tenant-scoped server fn receive tenantId as an explicit input.
todos:
  - id: bootstrap_reshape
    content: Collapse AppBootstrap type and rewrite getAppBootstrapData to accept an explicit tenantId input
    status: pending
  - id: tenant_pref_lib
    content: Add src/lib/tenant-preference.ts with SSR-safe localStorage helpers and resolveSelectedTenant
    status: pending
  - id: authed_loader
    content: Set _authed to ssr false and call bootstrap with tenantId resolved from localStorage against tenants
    status: pending
  - id: tenant_provider
    content: Add TenantProvider and useCurrentTenant that expose currentTenant and setCurrentTenant with router.invalidate
    status: pending
  - id: server_fns_tenantid
    content: Change campaigns server fns to take tenantId as input and drop requireBootstrapWithTenant
    status: pending
  - id: loader_deps_wiring
    content: Add loaderDeps tenantId to tenant-scoped routes and forward into server fns
    status: pending
  - id: app_header_context
    content: Wire AppHeader and organizations page to useCurrentTenant / setCurrentTenant
    status: pending
  - id: theme_pref
    content: Add theme-preference.ts + ThemeProvider mirroring the tenant pattern
    status: pending
  - id: docs_update
    content: Add 'Tenant selection' section to docs/README.md
    status: pending
isProject: false
---

## Scope

- Single source of truth for "which tenant is selected" is a client-only `localStorage` key. Never in the URL, never in a cookie.
- `_authed` opts out of SSR (`ssr: false`) so its loader (and all child route loaders) only run in the browser where `localStorage` is readable. Login and any public routes continue to SSR normally.
- `getAppBootstrapData` accepts `tenantId` as input and returns `{ user, tenants, currentTenant }` in one call — no extra client-side resolution round-trip.
- Every tenant-scoped server fn (campaigns etc.) takes `tenantId` as an explicit input arg.
- All tenant-scoped routes keep their existing TanStack loader pattern; they just declare `loaderDeps: () => ({ tenantId: readSelectedTenantId() })` and forward it into their server fn calls.
- `AppBootstrap` type is collapsed to one canonical shape.
- Theme preference uses the same localStorage pattern in parallel.

## Data flow

```mermaid
sequenceDiagram
    participant Browser
    participant LocalStorage as localStorage
    participant AuthedLoader as _authed loader (client only)
    participant ChildLoader as tenant-scoped loader
    participant ServerFn as tenant-scoped server fn
    Browser->>AuthedLoader: client-side load
    AuthedLoader->>LocalStorage: readSelectedTenantId
    AuthedLoader->>AuthedLoader: resolveSelectedTenant(storedId, tenants)
    note over AuthedLoader: falls back to most recent; writes back to localStorage if stale
    AuthedLoader->>ServerFn: getAppBootstrapData({ tenantId })
    ServerFn-->>AuthedLoader: { user, tenants, currentTenant }
    AuthedLoader-->>ChildLoader: loader data
    ChildLoader->>LocalStorage: readSelectedTenantId (via loaderDeps)
    ChildLoader->>ServerFn: fetchCampaignsList({ tenantId })
    ServerFn-->>ChildLoader: campaigns
    Browser->>Browser: setCurrentTenant(newId) writes localStorage and router.invalidate()
```

## Step 1 — Bootstrap reshape

Update `[src/types/bootstrap.ts](src/types/bootstrap.ts)` to drop duplicates:

```ts
export type AppBootstrap = {
  user: User;
  tenants: Tenant[];
  currentTenant: Tenant | null;
};
```

Rewrite `[src/server/app-bootstrap.ts](src/server/app-bootstrap.ts)`:

- `getAppBootstrapData` takes `.inputValidator(z.object({ tenantId: z.number().optional() }))`.
- Resolves `currentTenant` by matching `tenantId` against the fetched `tenants` list; `null` if no match or no input.
- Remove `tenant`, `currentUser`, `users` from the return and update every consumer.

## Step 2 — Client tenant preference module

New `[src/lib/tenant-preference.ts](src/lib/tenant-preference.ts)` — SSR-safe:

```ts
const KEY = "org-next:selected-tenant-id";

export function readSelectedTenantId(): number | null {
  if (typeof window === "undefined") return null;
  const raw = window.localStorage.getItem(KEY);
  const n = raw ? Number.parseInt(raw, 10) : NaN;
  return Number.isFinite(n) ? n : null;
}

export function writeSelectedTenantId(id: number): void {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(KEY, String(id));
}

export function resolveSelectedTenant(
  tenants: Tenant[],
  storedId: number | null,
): Tenant | null {
  if (tenants.length === 0) return null;
  const stored = storedId ? tenants.find((t) => t.id === storedId) : undefined;
  if (stored) return stored;
  return [...tenants].sort((a, b) =>
    b.created_at.localeCompare(a.created_at),
  )[0];
}
```

This single helper handles all three spec cases:

- No stored id → most recent.
- Stored id not in tenants → most recent.
- Stored id in tenants → that tenant.

## Step 3 — `_authed` loader with `ssr: false`

In `[src/routes/_authed.tsx](src/routes/_authed.tsx)`:

```ts
export const Route = createFileRoute("/_authed")({
  ssr: false,
  loader: async ({ location }) => {
    const tenantsOnly = await getAppBootstrapData();
    if (!tenantsOnly && !env.VITE_TEMP_BYPASS_AUTH) throw redirect({ to: "/login" });

    const onOrganizationsNewRoute =
      location.pathname === "/organizations/new" ||
      location.pathname.endsWith("/organizations/new");

    if (tenantsOnly.user && tenantsOnly.tenants.length === 0 && !onOrganizationsNewRoute) {
      throw redirect({ to: "/organizations/new" });
    }

    const resolved = resolveSelectedTenant(
      tenantsOnly.tenants,
      readSelectedTenantId(),
    );
    if (resolved && resolved.id !== readSelectedTenantId()) {
      writeSelectedTenantId(resolved.id);
    }

    return resolved
      ? await getAppBootstrapData({ data: { tenantId: resolved.id } })
      : tenantsOnly;
  },
  component: AuthedLayout,
});
```

Because `ssr: false` makes this loader client-only, `readSelectedTenantId()` and `writeSelectedTenantId()` are safe to call directly. Remove the stray `console.log`. The "no tenants → organizations/new" redirect now keys off `tenants.length === 0` since there is no longer a `tenant` field.

(Option to optimize later: collapse the two bootstrap calls into one by teaching the server fn to return most-recent-by-default when no tenantId is supplied. Not required in this pass.)

## Step 4 — Tenant provider / context

New `[src/components/tenant-provider.tsx](src/components/tenant-provider.tsx)`:

- Reads `{ tenants, currentTenant }` from `getRouteApi("/_authed").useLoaderData()`.
- Exposes `{ currentTenant, tenants, setCurrentTenant(id) }` via React context.
- `setCurrentTenant` calls `writeSelectedTenantId(id)` then `router.invalidate()`, which reruns `_authed` and all child loaders (child loaders already depend on tenantId via `loaderDeps`, so their server calls refetch under the new tenant).
- Mounted inside `AuthedLayout`, wrapping `<Outlet />`.

Companion hook:

```ts
export function useCurrentTenant(): {
  currentTenant: Tenant;
  tenants: Tenant[];
  setCurrentTenant: (id: number) => void;
};
```

Because `_authed` redirects to `/organizations/new` when `tenants.length === 0`, the provider can assert `currentTenant` is non-null for its descendants and throw if not (defensive, cheap).

## Step 5 — Tenant-scoped server fns take `tenantId`

In `[src/routes/_authed/campaigns/-campaigns.ts](src/routes/_authed/campaigns/-campaigns.ts)` and `[src/server/campaigns.ts](src/server/campaigns.ts)`:

- Change each `createServerFn` validator to include `tenantId: z.number()`.
- Resolve the `Tenant` inside the handler via `getOrgApiJson<Tenant>(\`/tenants/\${tenantId}\`)` (the Org API already authorizes by session) and build the scoped path with the existing `campaignApiScopeFromTenant` helper.
- Delete `requireBootstrapWithTenant`. Server fns no longer call `getAppBootstrapData` for tenant resolution.

Affected fns: `fetchCampaignsList`, `fetchCampaign`, `updateCampaign`, `createCampaignForCurrentTenant`, `createCampaign`, `getCampaignDetail`, `listCampaigns`.

Update the matching callers (loaders, `useCreateCampaign`) to forward `tenantId` — next step.

## Step 6 — `loaderDeps` on tenant-scoped routes

Keep the existing loader pattern; add `loaderDeps` that sources tenantId from localStorage. Because `_authed` is `ssr: false`, child loaders only run on the client, so this is safe.

- `[src/routes/_authed/index.tsx](src/routes/_authed/index.tsx)` (dashboard):
  - `loaderDeps: () => ({ tenantId: readSelectedTenantId() })`.
  - `loader: ({ deps: { tenantId } }) => getDashboardData({ data: { tenantId } })`.
  - `getDashboardData` becomes a server fn with `z.object({ tenantId: z.number() })` that internally calls `fetchCampaignsList` with the same tenantId. Remove the now-unnecessary `getAppBootstrapData()` call inside it.
- `[src/routes/_authed/campaigns/$campaignId.tsx](src/routes/_authed/campaigns/$campaignId.tsx)`:
  - `loaderDeps: () => ({ tenantId: readSelectedTenantId() })`.
  - `loader: ({ deps, params }) => getCampaignDetail({ data: { tenantId: deps.tenantId, campaignId: params.campaignId } })`.
- `[src/hooks/use-create-campaign.ts](src/hooks/use-create-campaign.ts)`: read `tenantId` from `useCurrentTenant()` inside the hook and pass it to `createCampaign`.

Router `invalidate()` after a tenant switch naturally reruns these loaders with the new `tenantId`.

## Step 7 — `AppHeader` and pages consume the context

- `[src/components/app-header.tsx](src/components/app-header.tsx)`: remove hard-coded `"test"` and `"DU"`. Pull tenant name + initials from `useCurrentTenant()`, and user email initial from the `_authed` loader data (`user.email[0]`).
- `[src/routes/_authed/organizations/index.tsx](src/routes/_authed/organizations/index.tsx)`: `handleSelectOrg` calls `setCurrentTenant(org.id)` then navigates to `/`.
- Replace every reference to the old duplicate fields (`tenant`, `currentUser`, `users`) with `user`, `tenants`, and `currentTenant`.

## Step 8 — Theme preference (mirrors tenant pattern)

- `[src/lib/theme-preference.ts](src/lib/theme-preference.ts)` — same read/write shape. Key: `org-next:theme`. Values: `"light" | "dark" | "system"`.
- `[src/components/theme-provider.tsx](src/components/theme-provider.tsx)` mounted in `[src/routes/__root.tsx](src/routes/__root.tsx)`. On mount reads localStorage, applies the right class to `document.documentElement`. Exposes `useTheme()`.
- No UI toggle in this pass — plumbing only.

## Step 9 — Docs update

New section in `[docs/README.md](docs/README.md)`: "Tenant selection".

- Source of truth is `localStorage` (`org-next:selected-tenant-id`).
- `_authed` is `ssr: false`; its loader resolves `currentTenant` via `resolveSelectedTenant` (stored id if valid, else most-recent-created, writing back to localStorage when stale).
- Tenant-scoped server fns take `tenantId` as an explicit input; tenant-scoped routes pass it via `loaderDeps`.
- `setCurrentTenant` writes localStorage and calls `router.invalidate()` to refetch everything tenant-scoped.
- Theme follows the same pattern under `org-next:theme`.

## Out of scope / follow-ups

- Cross-tab sync via the `storage` event.
- Tenant switcher UI in `AppHeader`.
- Theme toggle UI.
- Optional optimization: server-side "most recent by default" in `getAppBootstrapData` to collapse the two-call bootstrap in Step 3.
