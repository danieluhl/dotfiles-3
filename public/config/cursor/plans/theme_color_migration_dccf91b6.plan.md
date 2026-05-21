---
name: Theme color migration
overview: "Replace raw Tailwind palette classes with design tokens from `@workspace/ui/theme.css`: semantic tokens, extended scales (`primary-*`, `secondary-*`, `tertiary-*`), new **success** / **warning** semantics, plus chart tokens where appropriate. **Locked decisions:** migrate legacy apps to **`theme.css`** (not globals-only); add **`--success` / `--warning`** (light + dark) in theme and `@theme inline`; deliver as **one PR**. ~84 TS/TSX files match today; largest clusters: **`apps/org`**, **`packages/ui`**, **`apps/auth`**, **`apps/donor`**."
todos:
  - id: css-entrypoints
    content: Switch org/donor/builder/storybook from globals-only to theme.css; resolve import order / duplicate base styles if any component still pulls globals.css
    status: completed
  - id: success-warning-tokens
    content: Add --success, --warning (and foreground if needed) in theme.css :root/.dark + @theme inline; map greens/ambers/yellows to text-success, bg-warning/10, etc.
    status: completed
  - id: migrate-ui-package
    content: Replace raw palette classes in packages/ui (sidebar, inputs, searchable-*, radio-button-group, card, badge, typography, app-shell)
    status: completed
  - id: migrate-form-storybook
    content: Update packages/form + storybook/examples to theme tokens
    status: completed
  - id: migrate-apps
    content: Migrate apps/org (bulk), auth, donor, public-pages, builder, org-next
    status: completed
  - id: verify-docs
    content: Run lint/typecheck (repo validate or scoped); update packages/ui README for theme.css as canonical app entrypoint + new tokens
    status: completed
isProject: false
---

# Migrate Tailwind palette classes to UI theme tokens

## Locked decisions (stakeholder alignment)

1. **CSS strategy**: Migrate **org**, **donor**, **builder**, and **storybook** from **`@workspace/ui/globals.css`-only** to **`@workspace/ui/theme.css`** as the canonical full theme (same direction as auth / org-next / public-pages). Verify no conflicting double-import of globals + theme in the same app without intent; resolve **packages/ui** `build:css` / Postcss output if anything still assumes `globals.css` only.
2. **Success / warning**: Add **`--success`** and **`--warning`** (and **`--success-foreground` / `--warning-foreground`** if needed for contrast) in [`packages/ui/src/styles/theme.css`](packages/ui/src/styles/theme.css) for `:root` and `.dark`, register them under `@theme inline`, then replace raw greens / yellows / ambers with utilities like **`text-success`**, **`bg-success/10`**, **`border-warning`**, etc.
3. **Delivery**: **Single PR** touching foundation + all listed apps/packages (still implement in a sensible order: tokens + imports → `packages/ui` → apps).

## Context

- **Source of truth**: [`packages/ui/src/styles/theme.css`](packages/ui/src/styles/theme.css) — primary scale = slate, **`secondary-*`** = blue scale; semantic shadcn tokens; **`chart-*`** for categorical color.
- **Naming trap**: **`bg-secondary`** = shadcn secondary surface; **`bg-secondary-600`** = blue scale step. Use numeric utilities for “Tailwind blue” replacements.

## Implementation order

1. **Entrypoints**: Replace `import "@workspace/ui/globals.css"` with `import "@workspace/ui/theme.css"` where applicable (org shell, donor root, builder shell, storybook preview). Confirm auth/public-pages/org-next stay consistent (already on `theme.css`).
2. **New tokens**: Implement success/warning in `theme.css` (pick OKLCH values aligned with existing chart/destructive quality; ensure dark mode reads correctly).
3. **Replace classes** across [`packages/ui`](packages/ui/src), [`packages/form`](packages/form/src), and apps using the mapping below.
4. **Verify**: `pnpm run validate` or at minimum lint + typecheck for touched workspaces; spot-check high-visibility surfaces (org sidebar, auth flows, CSV modal, donor error boundary).

## Mapping guide

| Typical raw class | Prefer |
|-------------------|--------|
| `text-slate-*`, `text-gray-*`, `text-neutral-*` | `text-foreground`, `text-muted-foreground`, `text-primary-*` |
| `border-slate-*`, `border-gray-*` | `border-border` or `border-input` |
| `bg-slate-50`, `bg-gray-100`, … | `bg-muted`, `bg-accent`, `bg-primary-100`, `bg-secondary-50` |
| `bg-white` / `text-gray-900` | `bg-background` / `bg-card`, `text-foreground`, `text-card-foreground` |
| `blue-*` (brand / links) | **`secondary-*`** |
| `red-*` (errors) | `destructive` family |
| `green-*` (success) | **`success`** family (after tokens land) |
| `yellow-*` / `amber-*` (warnings) | **`warning`** family (after tokens land) |
| `teal-*` | `tertiary-*` or `chart-2` where semantic fit |
| Focus `ring-blue-500` | `ring-ring` or `ring-secondary-500` |
| Sidebar chrome | **`sidebar-*`** |

**Special cases**

- [`packages/ui/src/components/ui/badge.tsx`](packages/ui/src/components/ui/badge.tsx): `text-slate-900` → `text-foreground` or `text-card-foreground` by surface.
- [`packages/ui/src/components/typography/text.tsx`](packages/ui/src/components/typography/text.tsx): success variant → `text-success` (once token exists).
- [`packages/ui/src/components/radio-button-group.tsx`](packages/ui/src/components/radio-button-group.tsx): map neutrals/blues to theme tokens for light + dark.

## Rollout by area (single PR)

- **packages/ui**: Searchable dropdowns/lists, sidebar, inputs, radio group, card, badge, typography, app-shell, nav, table layout, examples.
- **packages/form**: switch field + stories.
- **apps/org**: bulk (app-shell icons, finance CSV modal, metric cards, tables, media manager, hooks).
- **apps/auth**, **donor**, **public-pages**, **builder**, **org-next**: remaining grep hits; org-next marketing carousel gradients → **`warning` / `success` / `tertiary`** as appropriate instead of raw `amber-50`, `yellow-50`, `teal-50`.
- **Storybook**: story files + [`tab-panel.example.tsx`](packages/ui/src/components/tab-panel.example.tsx).

## Documentation

- Update [`packages/ui/README.md`](packages/ui/README.md): **`theme.css`** is the canonical app import; document **`success`** / **`warning`** tokens once added.
