---
name: Sidebar tenant logo trigger
overview: Replace the full-width tenant text button in the sidebar header with a brand logo–forward trigger that stays visible and clickable when the sidebar is in icon mode, while keeping the existing Radix/shadcn dropdown menu for the tenant list.
todos:
  - id: update-app-sidebar
    content: "Refactor app-sidebar tenant DropdownMenuTrigger: AnedotTypemarkIcon, useSidebar collapsed layout, menu side/align"
    status: completed
  - id: manual-verify
    content: Verify expanded/collapsed tenant switch and menu position in browser
    status: completed
isProject: false
---

# Sidebar tenant switcher: logo trigger + collapsed behavior

## Current state

- [`apps/org-next/src/components/app-sidebar.tsx`](apps/org-next/src/components/app-sidebar.tsx) uses `DropdownMenu` with a full-width `Button` showing **tenant name + `ChevronsUpDown`**. In collapsed mode, the sidebar is narrow ([`--sidebar-width-collapsed` 48px](packages/ui/src/components/ui/sidebar.tsx)); long text does not fit well and the control does not read as a “logo” affordance.
- [`Tenant`](apps/org-next/src/types/bootstrap.ts) has no image URL; **brand** logo is the right always-available asset (`AnedotTypemarkIcon`, already used in [`app-header.tsx`](apps/org-next/src/components/app-header.tsx)).

## Recommended UX

- **Trigger**: One clickable control that always shows the **Anedot typemark** (scaled for sidebar, e.g. ~22–28px width) so it reads as a logo/button.
- **Expanded sidebar**: Logo + **truncated tenant name** + chevron (same information as today, clearer hierarchy).
- **Collapsed sidebar**: **Logo only** in a square, centered hit target (e.g. `h-10 w-10` or `size-10`) so the brand stays visible and the menu stays reachable.
- **Menu**: Keep **`DropdownMenu` / `DropdownMenuContent` / `DropdownMenuItem`** from `@workspace/ui` — same accessibility and keyboard behavior as now, with a more intentional trigger. No need for a separate Popover unless you hit a specific interaction bug.

## Implementation (single file)

**File:** [`apps/org-next/src/components/app-sidebar.tsx`](apps/org-next/src/components/app-sidebar.tsx)

1. **`useSidebar()`** from `@workspace/ui` (already exported from [`packages/ui/src/components/ui/sidebar.tsx`](packages/ui/src/components/ui/sidebar.tsx)) to read `collapsed`.
2. **`AnedotTypemarkIcon`** from `@workspace/ui` — same brand as the header; small size in sidebar.
3. **Restructure `DropdownMenuTrigger`** (still `asChild`):
   - Apply `cn()` so when `collapsed` is true: compact square (`size-10`, `p-0`, `justify-center`), no text/chevron.
   - When `collapsed` is false: row layout (`flex`, `gap-2`, `min-w-0`), `truncate` on tenant name, chevron at end.
   - **Accessibility**: `aria-label` should describe the action (e.g. “Switch organization” or keep “Select tenant”) and optionally include current tenant name when collapsed (text-only users).
4. **`DropdownMenuContent`**: Use `side` / `align` / `sideOffset` so the menu opens **to the right** when collapsed (or always), avoiding clipping under the narrow rail — e.g. `side={collapsed ? "right" : "bottom"}` and `align="start"` (tune after visual check).
5. **Optional polish**: `title={currentTenant?.name ?? "Select tenant"}` on the trigger when collapsed for native hover hint; or wrap with `Tooltip` from `@workspace/ui` if you want styled tooltips (watch for Radix tooltip vs dropdown focus quirks—`title` is the low-risk default).

**Empty state:** Leave “No tenants yet” as-is; no logo-only switcher needed.

## Files touched

| File | Change |
|------|--------|
| [`apps/org-next/src/components/app-sidebar.tsx`](apps/org-next/src/components/app-sidebar.tsx) | Logo + responsive trigger; `useSidebar`; optional menu positioning |

No changes to layout ([`_authed.tsx`](apps/org-next/src/routes/_authed.tsx)) or sidebar package unless you later want `SidebarHeader` to carry `data-sidebar` for unrelated flyout behavior.

## Verification

- Toggle sidebar: expanded shows logo + name + chevron; collapsed shows **only logo**, still opens dropdown.
- Select a tenant: existing `setSelectedTenantId` + check mark behavior unchanged.
- Keyboard: trigger still focuses and opens menu via Radix dropdown.
