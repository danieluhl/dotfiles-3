---
name: virtual-terminal app
overview: Add a new `apps/virtual-terminal` TanStack Start application on port 3211, modeled after the reusable parts of `apps/org-next` while keeping the app empty except for a hello-world route. The app will participate in the workspace’s existing Turbo, Biome, TypeScript, Vitest, and Fallow quality gates without carrying any `org-next` references.
todos:
  - id: scaffold-app
    content: Scaffold the `apps/virtual-terminal` package, TanStack Start app files, route files, and static-analysis configs.
    status: completed
  - id: sync-generated
    content: Sync generated artifacts and package metadata, including `pnpm-lock.yaml` and `src/routeTree.gen.ts`.
    status: completed
  - id: validate-app
    content: Run targeted virtual-terminal build, typecheck, lint, test, and fallow checks through mise.
    status: completed
  - id: audit-references
    content: Search the finished app for accidental `org-next`/port/auth/test-mocking references and note any docs decision.
    status: completed
isProject: false
---

# Virtual Terminal App Plan

## Assumptions
- Build the conservative, empty baseline: copy the reusable TanStack Start app shape from [`apps/org-next`](apps/org-next) and [`apps/auth`](apps/auth), but do not bring over auth, tenants, Rollbar, RMP, Playwright fixtures, app bootstrap, or org API code.
- Start without Playwright e2e files. The app will still have `test` via Vitest with `passWithNoTests`, plus `build`, `typecheck`, `lint`, `check`, and `fallow` scripts.
- Running the app means `pnpm --filter virtual-terminal dev`, serving on `http://localhost:3211` with `strictPort: true`.

## Implementation Shape
- Create [`apps/virtual-terminal/package.json`](apps/virtual-terminal/package.json) with the same basic scripts as `org-next`: `dev`, `build`, `serve`, `test`, `typecheck`, `clean`, `coverage`, `format`, `lint`, `check`, `check:fix`, `fallow`, and `fallow:fix`.
- Use only dependencies needed by the empty app shell: TanStack Start/Router, React, Nitro, Vite, Tailwind/Vite CSS tooling, shared workspace UI theme if the stylesheet imports it, TypeScript, Vitest, Biome, and Fallow. Avoid unused dependencies so Fallow does not start with dependency noise.
- Add [`apps/virtual-terminal/vite.config.ts`](apps/virtual-terminal/vite.config.ts) based on the shared TanStack Start config pattern, with `server.port = 3211`, `strictPort: true`, the `@` alias, Vite TS config paths, Tailwind, React, TanStack Start, Nitro outside Vitest, Vitest `passWithNoTests`, and shared watch ignores.
- Add [`apps/virtual-terminal/tsconfig.json`](apps/virtual-terminal/tsconfig.json), [`apps/virtual-terminal/biome.jsonc`](apps/virtual-terminal/biome.jsonc), and [`apps/virtual-terminal/.fallowrc.json`](apps/virtual-terminal/.fallowrc.json) aligned with `org-next`, adjusted for the smaller app structure.

## App Skeleton
- Create a minimal route tree under [`apps/virtual-terminal/src/routes`](apps/virtual-terminal/src/routes):
  - `__root.tsx` defines the document shell, imports app CSS, sets the page title to `Virtual Terminal`, and renders `<Outlet />` plus scripts.
  - `index.tsx` defines `/` and renders a plain `Hello world` view.
- Create [`apps/virtual-terminal/src/router.tsx`](apps/virtual-terminal/src/router.tsx) using the simple `apps/auth` pattern: `createRouter({ routeTree, defaultPreload: "intent", context: {} })`.
- Add [`apps/virtual-terminal/src/styles.css`](apps/virtual-terminal/src/styles.css) as a tiny blank-friendly stylesheet, likely keeping Tailwind and shared theme imports if they are part of the chosen dependency baseline.
- Generate [`apps/virtual-terminal/src/routeTree.gen.ts`](apps/virtual-terminal/src/routeTree.gen.ts) through the TanStack build/dev tooling rather than hand-authoring it.

## Repository Integration
- Rely on [`pnpm-workspace.yaml`](pnpm-workspace.yaml) `apps/*` discovery, so no workspace package list update should be needed.
- Update [`pnpm-lock.yaml`](pnpm-lock.yaml) by running the repo package manager through mise after adding the new package.
- Check whether a short [`apps/virtual-terminal/README.md`](apps/virtual-terminal/README.md) is useful for port and command documentation. Do not add an AI-maintained docs layer unless the new app gains behavior worth documenting.
- Search the new app for `org-next`, `Org Next`, port `3210`, auth, tenant, and RMP references before finishing.

## Verification
- Run targeted checks with the mise toolchain:
  - `mise exec -- pnpm install --lockfile-only` or equivalent dependency sync if the lockfile needs the new importer.
  - `mise exec -- pnpm --filter virtual-terminal build` to generate and validate the TanStack route tree.
  - `mise exec -- pnpm --filter virtual-terminal typecheck`.
  - `mise exec -- pnpm --filter virtual-terminal lint`.
  - `mise exec -- pnpm --filter virtual-terminal test`.
  - `mise exec -- pnpm --filter virtual-terminal fallow`.
- If time permits, run the broader workspace gate relevant to the change, preferably `mise exec -- pnpm run validate`, but call out if it is too slow or blocked.

todos:
- Scaffold the `apps/virtual-terminal` package, app files, config files, and scripts.
- Generate/update lockfile and TanStack route tree using the repo’s mise-managed pnpm toolchain.
- Run targeted validation for build, typecheck, lint, test, and fallow.
- Audit the new app for accidental `org-next` references and summarize any docs decision.