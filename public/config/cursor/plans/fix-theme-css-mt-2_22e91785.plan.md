---
name: fix-theme-css-mt-2
overview: Fix the Tailwind v4 build error by adding an `@reference "tailwindcss"` directive at the top of the shared `theme.css` so default utilities (`mt-2`, `w-72`, etc.) used inside `@apply` resolve when the file is imported as a standalone Vite/PostCSS module.
todos:
  - id: add-reference
    content: Add `@reference "tailwindcss";` as the first line of `packages/ui/src/styles/theme.css`.
    status: completed
  - id: rebuild-ui
    content: Run `pnpm --filter @workspace/ui build:css` to regenerate `packages/ui/dist/theme.css`.
    status: completed
  - id: verify-build
    content: Re-run the failing app build (and ideally `pnpm build`) to confirm the `Cannot apply unknown utility class mt-2` error is resolved.
    status: completed
isProject: false
---

# Fix `[postcss] tailwindcss: Cannot apply unknown utility class mt-2` in `packages/ui/dist/theme.css`

## Root cause

`packages/ui/src/styles/theme.css` uses `@apply` with default Tailwind utilities inside `@layer components` (lines ~256–282), e.g. the `.dropdown-menu` rule:

```265:269:packages/ui/src/styles/theme.css
@layer components {
  .dropdown-menu {
    @apply bg-sidebar-background absolute mt-2 w-72 rounded-lg shadow-lg ring-1 ring-black/5 focus:outline-none;
    z-index: 50;
  }
```

In Tailwind v4, when a CSS file is processed as a **standalone Vite/PostCSS module** (i.e. imported from JS/TSX rather than inlined via `@import` inside a file that already has `@import "tailwindcss"`), Tailwind has no theme/utility context for that file and `@apply mt-2` fails with `Cannot apply unknown utility class \`mt-2\``. See the [Tailwind v4 `@reference` docs](https://tailwindcss.com/docs/functions-and-directives#reference-directive).

Apps split into two patterns today:

- `@import` pattern (works today): `styles.css` has `@import "tailwindcss"` then `@import "@workspace/ui/theme.css"`. PostCSS inlines both into one file before Tailwind runs.
  - [apps/org-next/src/styles.css](apps/org-next/src/styles.css), [apps/auth/src/styles.css](apps/auth/src/styles.css), [apps/public-pages/src/styles.css](apps/public-pages/src/styles.css)
- JS-side import pattern (broken in v4): each `import "@workspace/ui/theme.css";` is processed in isolation.
  - [apps/donor/src/routes/__root.tsx](apps/donor/src/routes/__root.tsx) (recently changed from `globals.css` to `theme.css` in this WIP)
  - [apps/builder/src/components/app-shell.tsx](apps/builder/src/components/app-shell.tsx)
  - [apps/org/src/components/app-shell.tsx](apps/org/src/components/app-shell.tsx)
  - [apps/storybook/.storybook/preview.tsx](apps/storybook/.storybook/preview.tsx)

The error reports `packages/ui/dist/theme.css` because the package's `build:css` script just `cp`s the source: `mkdir -p dist && postcss src/styles/globals.css -o dist/globals.css && cp src/styles/theme.css dist/theme.css` (see [packages/ui/package.json](packages/ui/package.json) line 53).

## Fix

Add `@reference "tailwindcss";` as the first line of [packages/ui/src/styles/theme.css](packages/ui/src/styles/theme.css). This loads Tailwind's default theme/utilities for `@apply` resolution **without** duplicating CSS in the output. Custom tokens like `bg-sidebar-background` continue to work because they are declared in the same file's `@theme inline { ... }` block.

```css
@reference "tailwindcss";
@import "@fontsource-variable/instrument-sans";
/* ...rest unchanged... */
```

`tailwindcss` resolves through the consuming app's `node_modules`, so this works regardless of which app is bundling.

## Steps

- Edit [packages/ui/src/styles/theme.css](packages/ui/src/styles/theme.css): add `@reference "tailwindcss";` as the first line.
- Rebuild the package so `dist/theme.css` includes the directive: `pnpm --filter @workspace/ui build:css` (the script copies `src/styles/theme.css` to `dist/theme.css`).
- Re-run the failing build (e.g. `pnpm --filter donor build` or whichever app produced the original error) and confirm the PostCSS error is gone.

## Verification

- `pnpm run validate` from the repo root runs the full quality gate (lint, build, typecheck, test, e2e) per the workspace toolchain rule. At minimum, run `pnpm build` to confirm all apps that import `@workspace/ui/theme.css` build cleanly.