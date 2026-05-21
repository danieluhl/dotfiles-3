---
name: fix sidebar icon jump
overview: Replace the grid-based tenant switcher with a simple flex layout that pins the avatar to the left throughout the collapse transition, and hide the tenant-switcher bottom border when collapsed.
todos:
  - id: flex-layout
    content: Rewrite the `SidebarMenuButton` in `apps/org-next/src/components/app-sidebar.tsx` to use `flex ... justify-start` instead of `grid grid-cols-[...]`, keeping the avatar pinned with `shrink-0` and the label/chevron inside a `flex-1 min-w-0` wrapper.
    status: completed
  - id: hide-collapsed-border
    content: Hide the tenant-switcher `border-b` when the sidebar is collapsed in `apps/org-next/src/components/app-sidebar.tsx`.
    status: completed
  - id: verify
    content: Manually verify the collapse/expand animation keeps the avatar pinned to the left with no jump and no stray bottom border when collapsed.
    status: completed
isProject: false
---

## Root cause

`SidebarMenuButton` in [packages/ui/src/components/ui/sidebar.tsx](packages/ui/src/components/ui/sidebar.tsx) adds `justify-center` whenever `collapsed` is true:

```285:287:packages/ui/src/components/ui/sidebar.tsx
        menuButtonVariants({ size, variant }),
        collapsed ? "justify-center px-2" : "",
```

On our grid button that becomes `justify-content: center`. When you click collapse:

- `collapsed` flips true instantly, so the button gets `justify-content: center` right now.
- The sidebar width is the only element with the width transition, so it is still ~256px for the first frame.
- The single `2rem` grid column gets centered in the still-wide button — the avatar visually snaps to the right.
- As the sidebar shrinks to 48px, the centered track slides back to the left, producing the "jump then slide" feel.

Our existing `justify-items-start` / `justify-items-stretch` do not fix this — `justify-items` targets items inside their cells, not the placement of the grid tracks (which is `justify-content`). So twMerge leaves `justify-center` in place.

## Fix — switch to flex

The grid with `grid-cols-[2rem_...]` was only a workaround for the library's `justify-center`. With `justify-start` forcing the button's main-axis alignment to the start, plain flex is enough: the fixed-size avatar (`shrink-0`) always sits at the left edge, and the label/chevron sit next to it when expanded.

In [apps/org-next/src/components/app-sidebar.tsx](apps/org-next/src/components/app-sidebar.tsx), rewrite the `SidebarMenuButton` (lines ~51–88) as:

```tsx
<SidebarMenuButton
  aria-label={switcherAriaLabel}
  className={cn(
    "flex h-10 w-full items-center justify-start gap-2 text-sidebar-foreground shadow-none ring-0",
    "hover:bg-sidebar-accent/80 data-[state=open]:bg-sidebar-accent/90",
    "focus-visible:ring-0 focus-visible:ring-offset-0",
    "dark:hover:bg-sidebar-accent/50",
  )}
  disabled={isPending}
  size="md"
  title={collapsed ? tenantLabel : undefined}
  variant="default"
>
  <div aria-hidden className={cn(tenantLogoClasses, "shrink-0")}>
    {tenantInitials}
  </div>
  {!collapsed ? (
    <div className="flex min-w-0 flex-1 items-center gap-2">
      <span className="min-w-0 flex-1 truncate text-left font-semibold text-sidebar-foreground text-sm">
        {tenantLabel}
      </span>
      <ChevronsUpDown className="size-4 shrink-0 text-sidebar-foreground/50" />
    </div>
  ) : null}
</SidebarMenuButton>
```

Key points:
- `flex ... justify-start` overrides the library's `justify-center` via `twMerge` (same class group), so the avatar stays anchored at the button's left padding throughout the sidebar width transition — no jump.
- `shrink-0` on the avatar keeps it exactly `size-8` (2rem) even while the flex container shrinks during the sidebar's `width` transition 256 → 48.
- The label/chevron wrapper uses `min-w-0 flex-1` so the text can truncate when expanded. Removing it when `collapsed` is true is visually fine because the sidebar width animates from `256 → 48`, so the avatar simply ends up alone against the left edge. There is no extra `grid-template-columns` animation to worry about.
- The previous `transition-[grid-template-columns]` on the button is dropped; the only motion is the existing `width` transition on the `Sidebar` wrapper in the `@workspace/ui` package.
- The explanatory comment about the grid workaround can be removed.

## Hide collapsed bottom border

The tenant-switcher wrapper inside `SidebarHeader` currently always renders `border-b`:

```43:43:apps/org-next/src/components/app-sidebar.tsx
        <div className="border-sidebar-border border-b px-2 py-2">
```

When the sidebar collapses, that leaves a short horizontal rule under just the avatar, which looks out of place.

Update that line to conditionally drop the bottom border when `collapsed` is true, using the existing `collapsed` value from `useSidebar()` and `cn`:

```tsx
<div
  className={cn(
    "border-sidebar-border px-2 py-2",
    !collapsed && "border-b",
  )}
>
```

No other layout/padding changes — only the border visibility is tied to the collapsed state.

## Verification

- Collapse the sidebar and watch the avatar — it should remain anchored at the left and only the label/chevron should disappear while the sidebar shrinks.
- Confirm the horizontal rule under the tenant switcher disappears when collapsed and returns when expanded.
- Expand the sidebar — avatar stays put, label grows in, border reappears.
- Keyboard/screen reader behavior is unchanged (no structural edits).