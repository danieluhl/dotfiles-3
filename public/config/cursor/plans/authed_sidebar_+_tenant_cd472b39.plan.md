---
name: Authed sidebar + tenant
overview: Implement the shadcn sidebar and tenant switcher entirely in existing `_authed.tsx` (no extra layout route files, no route-tree moves). All `_authed` children including `/organizations/new` share this shell. With zero tenants the sidebar shows a short “none yet” message (no link); root-level loader redirect still sends users to `/organizations/new` when appropriate.
todos:
  - id: authed-layout-shell
    content: Extend `_authed.tsx` component with SidebarProvider, Sidebar (tenant UI), SidebarInset, Outlet; defaultCollapsed false
    status: completed
  - id: redirect-rules
    content: Keep/adjust `_authed` loader only — no tenant → redirect to `/organizations/new` except when already on that path (existing pattern)
    status: completed
  - id: sidebar-component
    content: Extract e.g. app-sidebar.tsx — tenant DropdownMenu when tenants exist; plain “No tenants yet” copy when none; SidebarFooter for collapse; getRouteApi("/_authed")
    status: completed
  - id: dedupe-headers
    content: Remove AppHeader from authed pages; strip duplicate inline header from organizations/new.tsx to match other routes
    status: completed
  - id: docs-touch
    content: Update apps/org-next/docs/README.md — single authed shell, redirect, file paths
    status: completed
isProject: false
---

# Authenticated layout: shadcn sidebar + tenant dropdown

## Context (already in the repo)

- **Layout hook**: [`apps/org-next/src/routes/_authed.tsx`](apps/org-next/src/routes/_authed.tsx) currently renders only `<Outlet />` and its loader redirects users with no tenant to `/organizations/new` (with an exception for that path). Bootstrap data comes from `getAppBootstrapData`.
- **Tenant switching**: [`apps/org-next/src/hooks/use-user-session.ts`](apps/org-next/src/hooks/use-user-session.ts) exposes `setSelectedTenantId` → `updateUserSession` + `router.invalidate()`.
- **shadcn / UI**: Sidebar and `DropdownMenu` live in `@workspace/ui` (see [`components.json`](apps/org-next/components.json)).
- **Theme**: [`apps/org-next/src/styles.css`](apps/org-next/src/styles.css) imports `@workspace/ui/theme.css` (`--sidebar-*` tokens).

## Decisions (updated)

- **Single layout file**: Implement the sidebar shell in **`_authed.tsx` only** — **no** pathless `_sidebar` route, **no** moving route files under a new folder, **no** second layout component file under `routes/` unless a presentational extract (e.g. `app-sidebar.tsx`) is needed for clarity.
- **Same shell for all authed routes**: **[`/organizations/new`](apps/org-next/src/routes/_authed/organizations/new.tsx)** uses the **same** `_authed` layout as home, campaigns, transactions, and organizations list — simplifies routing and avoids special-casing that page.
- **Zero tenants in the UI**: The sidebar **always mounts** under `_authed`. If there are **no tenants** (or nothing to select), show a short static message such as **“No tenants yet”** — **no** link to the create flow in the sidebar; navigation to create is handled by the **existing root-level loader redirect** (user hits `/` or other disallowed routes without a tenant → `/organizations/new`).
- **Sidebar contents (v1)**: Tenant switcher **when** `tenants.length > 0`; otherwise the empty copy above. **No** logo, user avatar, or primary nav in the sidebar (deferred).
- **After removing `AppHeader`**: **No** replacement inset header for v1 — main content starts beside the sidebar. Remove the **duplicate inline header** on `organizations/new.tsx` so it matches.
- **Collapse**: Use **`SidebarFooter`** from `@workspace/ui` so collapse/expand remains.

## Routing model (simplified)

```mermaid
flowchart TB
  subgraph authed [/_authed single file]
    L[Loader bootstrap plus redirects]
    SP[SidebarProvider]
    SB[Sidebar tenant UI]
    SI[SidebarInset]
    OUT[Outlet all child routes]
    L --> SP
    SP --> SB
    SP --> SI
    SI --> OUT
  end
```

1. **`_authed.tsx`**
   - **Loader**: Keep `getAppBootstrapData()`. Keep the **existing** redirect: authenticated and **no** resolvable tenant → `redirect({ to: "/organizations/new" })` **except** when `location.pathname === "/organizations/new"` (same idea as today’s `onOrganizationsNewRoute`). Adjust pathname check if the constant changes; no second layout loader.
   - **Component**: `SidebarProvider` (`defaultCollapsed={false}`) + flex row + `Sidebar` (tenant area + `SidebarFooter`) + `SidebarInset` + `<Outlet />`.

2. **Child routes**  
   - **No file moves** — leave [`_authed/index.tsx`](apps/org-next/src/routes/_authed/index.tsx), [`campaigns/$campaignId.tsx`](apps/org-next/src/routes/_authed/campaigns/$campaignId.tsx), [`transactions.tsx`](apps/org-next/src/routes/_authed/transactions.tsx), [`organizations/`](apps/org-next/src/routes/_authed/organizations/) as they are; only update imports / remove `AppHeader` where present.

## Sidebar UX

- **Default open**: `defaultCollapsed={false}` ([`sidebar-context.tsx`](../../packages/ui/src/components/ui/sidebar-context.tsx)).
- **Has tenants**: `DropdownMenu` listing tenants; `setSelectedTenantId` from `useUserSession()`; loading/disabled while mutation pending; optional check on active tenant.
- **No tenants**: Non-interactive copy (e.g. muted text) — **“No tenants yet”** (exact wording flexible); **no** `Link` to `/organizations/new` in the sidebar.
- **Data**: `getRouteApi("/_authed").useLoaderData()` for `tenants` / `currentTenant`.
- **`SidebarFooter`**: Keep for collapse control.

## Implementation steps (ordered)

1. **Shell in `_authed.tsx`**: Add sidebar structure + `<Outlet />` in the inset as described.
2. **Presentational helper** (optional): [`apps/org-next/src/components/app-sidebar.tsx`](apps/org-next/src/components/app-sidebar.tsx) for tenant block + footer to keep `_authed.tsx` readable.
3. **Strip headers**: Remove `AppHeader` from [`_authed/index.tsx`](apps/org-next/src/routes/_authed/index.tsx), [`campaigns/$campaignId.tsx`](apps/org-next/src/routes/_authed/campaigns/$campaignId.tsx), [`transactions.tsx`](apps/org-next/src/routes/_authed/transactions.tsx), and organizations pages as applicable; remove the **inline `<header>`** from [`organizations/new.tsx`](apps/org-next/src/routes/_authed/organizations/new.tsx). Delete or trim [`app-header.tsx`](apps/org-next/src/components/app-header.tsx) if unused.
4. **Docs**: [`apps/org-next/docs/README.md`](apps/org-next/docs/README.md) — one authed shell, sidebar behavior with/without tenants, redirect pointer to `_authed.tsx` loader.
5. **QA**: With tenants — sidebar open, switcher works. With zero tenants — message in sidebar, redirect from `/` (etc.) to `/organizations/new` still works; create-tenant page uses same shell without duplicate header.

## Out of scope (unless requested)

- Logo, user avatar, or primary nav links in the sidebar.
- Thin `SidebarInset` header row.
- New layout route files or route-tree restructuring.
- Porting [`AppShell`](../../packages/ui/src/components/app-shell/app-shell.tsx) from other apps.
