---
name: Unify terminology to organization
overview: Eliminate "workspace" from the codebase. Use "tenant" in code (matching the backend), "organization" or "vendor" in user-facing UI/URLs depending on type (defaulting to "organization"), and keep `@workspace/*` monorepo package imports untouched.
todos:
  - id: move-files
    content: "Move and rename route files: -workspace.ts, organizations.tsx, workspace/new.tsx into organizations/ directory"
    status: completed
  - id: update-authed-layout
    content: Update _authed.tsx redirect paths from /workspace/new to /organizations/new
    status: completed
  - id: update-organizations-index
    content: "Update organizations/index.tsx: fix imports, rename workspace variables to tenant, update all UI text"
    status: completed
  - id: update-organizations-new
    content: "Update organizations/new.tsx: route path, imports, variables, HTML ids, and all UI text"
    status: completed
  - id: update-server-files
    content: Rename getWorkspaceNewPageData in app-bootstrap.ts; update error messages in campaigns.ts and -campaigns.ts
    status: completed
  - id: update-lib-comments
    content: Update campaign-api-scope.ts comments to remove workspace references
    status: completed
  - id: update-tests
    content: Rename and update workspace-new.spec.ts to organizations-new.spec.ts with new URLs, selectors, and text
    status: completed
  - id: regen-route-tree
    content: Regenerate routeTree.gen.ts after file moves
    status: completed
  - id: update-docs
    content: Update docs/ if workspace-creation.md or organizations.md exist
    status: completed
isProject: false
---

# Unify entity terminology: eliminate "workspace"

## Terminology rules

- **In code** (types, variables, server functions): use **"tenant"** to match the backend API
- **In user-facing text and URLs**: use **"organization"** (default) or **"vendor"** depending on tenant type
- **`@workspace/*` package imports**: untouched (monorepo scope, not the entity)
- **"Organization" and "Vendor" as type labels**: stay as-is
- **`org-*` app-level names** (`OrgApiError`, `orgApiScopedPath`, `org-next`): untouched

## File moves and renames

The `/organizations` URL stays. The `/workspace/new` URL becomes `/organizations/new`. Route files reorganize into an `organizations/` directory:

```
BEFORE:                                    AFTER:
_authed/                                   _authed/
  -workspace.ts (createTenant)               organizations/
  organizations.tsx (/organizations)           -organizations.ts (createTenant, moved)
  workspace/                                   index.tsx (listing page, moved)
    new.tsx (/workspace/new)                   new.tsx (moved, path -> /organizations/new)
```

| Action | From | To |
|--------|------|----|
| Move + rename | `src/routes/_authed/-workspace.ts` | `src/routes/_authed/organizations/-organizations.ts` |
| Move | `src/routes/_authed/organizations.tsx` | `src/routes/_authed/organizations/index.tsx` |
| Move | `src/routes/_authed/workspace/new.tsx` | `src/routes/_authed/organizations/new.tsx` |
| Delete | `src/routes/_authed/workspace/` | (empty directory) |
| Rename | `tests/workspace-new.spec.ts` | `tests/organizations-new.spec.ts` |

## File-by-file content changes

### 1. [`src/routes/_authed.tsx`](src/routes/_authed.tsx) -- redirect path

- `onWorkspaceNewRoute` --> `onOrganizationsNewRoute`
- All `"/workspace/new"` string literals --> `"/organizations/new"`

### 2. `src/routes/_authed/organizations/index.tsx` (moved from [`organizations.tsx`](src/routes/_authed/organizations.tsx))

- Route definition: `createFileRoute("/_authed/organizations")` may need to become `"/_authed/organizations/"` (verify with route gen)
- Import: `from "./-tenants"` --> `from "./-organizations"` (fixes the existing broken import)
- **Variables**: `workspaceColors` --> `tenantColors`, `getWorkspaceColor` --> `getTenantColor`, `workspaceType`/`setWorkspaceType` --> `tenantType`/`setTenantType`
- **UI text**:
  - `"Your workspaces"` --> `"Your organizations"`
  - `"Select a workspace to continue, or create a new one."` --> `"Select an organization to continue, or create a new one."`
  - `"Create a workspace to get started..."` --> `"Create an organization to get started..."`
  - `"Create a new workspace"` --> `"Create a new organization"`
  - `"Create workspace"` / `"Creating workspace..."` --> `"Create organization"` / `"Creating organization..."`
  - `"Workspace name"` --> `"Organization name"`
  - `"Workspace type"` --> `"Type"`

### 3. `src/routes/_authed/organizations/new.tsx` (moved from [`workspace/new.tsx`](src/routes/_authed/workspace/new.tsx))

- Route: `createFileRoute("/_authed/workspace/new")` --> `createFileRoute("/_authed/organizations/new")`
- Import: `from "../-tenants"` --> `from "./-organizations"` (fixes broken import, new relative path)
- Import: `getWorkspaceNewPageData` --> `getOrganizationsNewPageData`
- **Variables**: `workspaceTypeOptions` --> `tenantTypeOptions`, form field `workspaceType` --> `tenantType`, `NewWorkspacePage` --> `NewOrganizationPage`
- **HTML ids**: `id="workspace-name"` --> `id="organization-name"`, `htmlFor` updated to match
- **UI text**:
  - `"Create your workspace"` --> `"Create your organization"`
  - `"A workspace is where you run campaigns..."` --> `"An organization is where you run campaigns..."`
  - `"Could not create your workspace..."` --> `"Could not create your organization..."`
  - `"Workspace name"` --> `"Organization name"`, `"Workspace type"` --> `"Type"`
  - `"Creating workspace..."` / `"Create workspace"` --> `"Creating organization..."` / `"Create organization"`
  - `"Already have access to a workspace?"` --> `"Already have access to an organization?"`
  - `"View your workspaces"` --> `"View your organizations"`

### 4. [`src/server/app-bootstrap.ts`](src/server/app-bootstrap.ts)

- `getWorkspaceNewPageData` --> `getOrganizationsNewPageData`

### 5. [`src/server/campaigns.ts`](src/server/campaigns.ts) and [`src/routes/_authed/campaigns/-campaigns.ts`](src/routes/_authed/campaigns/-campaigns.ts)

Both contain the same duplicated message. In each:
- `"Only organization workspaces can create campaigns"` --> `"Only organizations can create campaigns"`

### 6. [`src/lib/campaign-api-scope.ts`](src/lib/campaign-api-scope.ts) -- comments only

- `"current workspace tenant"` --> `"current tenant"`
- `"vendor workspaces"` --> `"vendor tenants"`

### 7. `tests/organizations-new.spec.ts` (renamed from [`workspace-new.spec.ts`](tests/workspace-new.spec.ts))

- URLs: `/workspace/new` --> `/organizations/new`
- Selectors: `#workspace-name` --> `#organization-name`
- Button text: `"Create workspace"` --> `"Create organization"`
- Test descriptions: `"creates an organization workspace"` --> `"creates an organization tenant"`

### 8. Docs (if files exist)

- [`docs/features/workspace-creation.md`](docs/features/workspace-creation.md) and [`docs/features/organizations.md`](docs/features/organizations.md) -- rename/update if present. The glob found them but reads returned "not found" (may be on a different branch). Update or rename if they exist at implementation time.

### 9. `routeTree.gen.ts` -- auto-regenerated

Run TanStack Router codegen after file moves. All `AuthedWorkspaceNew*` references become `AuthedOrganizationsNew*` automatically.

## Not changed

- `@workspace/ui` and other `@workspace/*` imports (monorepo scope)
- [`src/types/bootstrap.ts`](src/types/bootstrap.ts) (`Tenant`, `TenantType` -- already correct)
- [`src/server/app-bootstrap.ts`](src/server/app-bootstrap.ts) tenant-related code (`fetchTenants`, `currentTenant`, etc.)
- [`src/lib/org-api-scoped-path.ts`](src/lib/org-api-scoped-path.ts) (app-level "org" naming)
- [`src/components/app-header.tsx`](src/components/app-header.tsx) (`showOrgSwitcher`, `currentTenantName` -- already aligned)
- [`src/routes/_login/signup.tsx`](src/routes/_login/signup.tsx) external URL `terms-for-fundraising-organizations`
- Type labels `"Organization"` and `"Vendor"` in option lists
