---
name: Tenant dropdown colors
overview: Fix tenant dropdown contrast by overriding the shared `@workspace/ui` dropdown classes in [`app-sidebar.tsx`](apps/org-next/src/components/app-sidebar.tsx) so the portal menu uses org-next surface tokens (`popover` / `accent`) instead of the mismatched `sidebar-background` + `sidebar-foreground` pair from the design system.
todos:
  - id: dropdown-tokens
    content: Override DropdownMenuContent + DropdownMenuItem classes in app-sidebar.tsx (popover + accent tokens)
    status: completed
  - id: verify-lint
    content: Run tsc + biome on app-sidebar.tsx
    status: completed
isProject: false
---

# Fix tenant dropdown foreground/background

## Root cause

[`packages/ui/src/components/ui/dropdown-menu.tsx`](packages/ui/src/components/ui/dropdown-menu.tsx) sets `DropdownMenuContent` to:

- `bg-sidebar-background text-sidebar-foreground`

In [`packages/ui/src/styles/theme.css`](packages/ui/src/styles/theme.css) (`:root` light mode), `--sidebar-background` is a **dark** indigo (`oklch(0.256 0.089 281.01)`, commented “indigo-900”) while `--sidebar-foreground` is **dark** slate text (`oklch(0.129...)`). That pairing yields **dark text on a dark panel** (or very poor contrast).

Your sidebar column uses `bg-sidebar` on [`AppSidebar`](apps/org-next/src/components/app-sidebar.tsx), which maps to the **`--sidebar`** token (light `oklch(0.984...)` in `:root`) — a different variable than `sidebar-background`. So the **dropdown portal** looks like a dark sheet while the rest of the shell reads light; text inherits `text-sidebar-foreground` and looks wrong.

`DropdownMenuItem` also uses `focus:bg-sidebar-accent` / `focus:text-sidebar-accent-foreground`, which are consistent with the broken mental model but do not fix default row text.

## Recommended fix (org-next only, minimal blast radius)

**Do not change** the shared package dropdown defaults (other apps may rely on them). **Override** in one place:

1. **`DropdownMenuContent`** in [`apps/org-next/src/components/app-sidebar.tsx`](apps/org-next/src/components/app-sidebar.tsx)  
   Add Tailwind classes so the menu matches standard app surfaces, e.g.  
   `bg-popover text-popover-foreground border-border`  
   (keep existing `min-w-56`, `align="start"`). These tokens are already defined for light/dark in the same theme file (`--popover`, `--popover-foreground`).

2. **`DropdownMenuItem`** (tenant rows)  
   Add base + focus overrides so rows match the popover surface and standard menu affordances, e.g.  
   `text-foreground focus:bg-accent focus:text-accent-foreground`  
   alongside existing `cursor-pointer gap-2`. Rely on `cn` / tailwind-merge in the UI package to resolve conflicting `focus:*` utilities with the defaults from `DropdownMenuItem`.

3. **Optional polish**  
   - Adjust the `Check` icon from `text-primary` to something that reads on popover if needed (often `text-primary` is fine).  
   - Quick visual check in browser: open tenant menu in light layout and confirm hover/focus states.

## Out of scope unless you ask

- Editing [`packages/ui` theme.css](packages/ui/src/styles/theme.css) to “fix” `--sidebar-background` / `--sidebar-foreground` globally (would affect every consumer of those tokens).  
- Changing the shared `dropdown-menu` component in `packages/ui` (broader impact).

## Verification

- Manual: authenticated home with multiple tenants — dropdown panel is light-on-light (or correct dark mode when `.dark` is applied), tenant names readable, hover/focus visible.  
- `pnpm exec tsc --noEmit` and `pnpm exec biome check` on the touched file.
