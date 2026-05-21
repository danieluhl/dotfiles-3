---
name: Vite 8 Migration Plan
overview: Migrate the monorepo from Vite 7.x (resolved 7.3.1) to Vite 8, which replaces esbuild/Rollup with the unified Rolldown bundler. This touches the pnpm catalog, 8 vite config files, plugin version bumps, and removal of now-default experimental flags.
todos:
  - id: bump-catalog
    content: "Update pnpm catalog: vite ^8.0.0, vitest ^4.1.0, @vitest/* ^4.1.0"
    status: pending
  - id: remove-experimental
    content: Remove experimental.enableNativePlugin from builder, org, donor vite configs
    status: pending
  - id: bump-plugin-react
    content: Bump @vitejs/plugin-react to v6 (or v5 minimum) across all 8 apps; consider adding to catalog
    status: pending
  - id: check-ecosystem
    content: "Verify/bump ecosystem plugins: @storybook/react-vite, @cloudflare/vite-plugin, @tanstack/*, nitro"
    status: pending
  - id: install-and-test
    content: pnpm install, then pnpm run validate -- fix any build/type/test failures
    status: pending
  - id: test-ssr-apps
    content: Manual testing of SSR apps (auth, org-next, public-pages) dev and build
    status: pending
  - id: optional-tsconfig-paths
    content: "Optional: replace vite-tsconfig-paths with built-in resolve.tsconfigPaths"
    status: pending
isProject: false
---

# Vite 8 Migration Plan

## Current State

- **Vite**: `^7.1.7` (resolved `7.3.1`) via pnpm catalog
- **Vitest**: `^4.0.18` (already Vite 8 compatible at `>=4.1`)
- **`@vitejs/plugin-react`**: mixed versions -- `^4.3.4`/`^4.7.0` (builder, org, donor, storybook) and `^5.0.4`/`^5.1.1` (auth, org-next, public-pages, prototype-org-next)
- **3 apps** (builder, org, donor) use `experimental.enableNativePlugin: true`
- **No** `rollupOptions`, `esbuildOptions`, or `manualChunks` usage in any vite config
- **No** custom Vite plugins in the repo

## What Vite 8 Changes

Vite 8 replaces esbuild + Rollup with [Rolldown](https://rolldown.rs/) (Rust-based bundler). Key breaking changes:

- `build.rollupOptions` renamed to `build.rolldownOptions` (not used in this repo)
- `optimizeDeps.esbuildOptions` deprecated in favor of `rolldownOptions` (not used)
- `esbuild` config deprecated in favor of `oxc` (not used)
- `experimental.enableNativePlugin` is now the default -- the flag should be removed
- Default browser targets bumped (Chrome 111, Firefox 114, Safari 16.4)
- `@vitejs/plugin-react` v6 ships alongside (uses Oxc instead of Babel); v5 still works with Vite 8
- CJS interop behavior changed -- may surface import issues with some deps
- Node.js 20.19+ or 22.12+ required (same as Vite 7)
- Vite 8 now has built-in `resolve.tsconfigPaths` option, potentially replacing `vite-tsconfig-paths`

## Migration Steps

### 1. Bump Vite in the pnpm catalog

In [`pnpm-workspace.yaml`](pnpm-workspace.yaml), change the catalog entry:

```yaml
vite: ^8.0.0
```

### 2. Bump Vitest to 4.1+

Vitest 4.1 added Vite 8 peer dependency support. Update the catalog:

```yaml
vitest: ^4.1.0
# Also bump the companion packages:
'@vitest/browser': ^4.1.0
'@vitest/browser-playwright': ^4.1.0
'@vitest/coverage-v8': ^4.1.0
```

### 3. Upgrade `@vitejs/plugin-react`

v6 is the Vite 8 companion release (drops Babel, uses Oxc). v5 still works but is not recommended long-term. The repo currently has a mix of v4 and v5 -- this is a good time to unify.

**Option A (recommended):** Bump all apps to `@vitejs/plugin-react@^6.0.0` and move it into the pnpm catalog for consistency.

**Option B (conservative):** Bump v4 apps to `^5.0.4` first (v5 works with Vite 8), defer v6 to a follow-up.

Apps to update:
- `apps/builder/package.json` -- currently `^4.7.0`
- `apps/org/package.json` -- currently `^4.7.0`
- `apps/donor/package.json` -- currently `^4.3.4`
- `apps/storybook/package.json` -- currently `^4.6.0`
- `apps/auth/package.json` -- currently `^5.0.4`
- `apps/org-next/package.json` -- currently `^5.0.4`
- `apps/public-pages/package.json` -- currently `^5.0.4`
- `apps/prototype-org-next/package.json` -- currently `^5.1.1`

### 4. Remove `experimental.enableNativePlugin`

Rolldown is now the default in Vite 8, so this flag is unnecessary. Remove from:

- [`apps/builder/vite.config.js`](apps/builder/vite.config.js) (lines 9-10)
- [`apps/org/vite.config.js`](apps/org/vite.config.js) (lines 8-9)
- [`apps/donor/vite.config.js`](apps/donor/vite.config.js) (lines 8-9)

### 5. Consider replacing `vite-tsconfig-paths` with built-in support

Vite 8 has built-in `resolve.tsconfigPaths: true`. This could replace the `vite-tsconfig-paths` plugin in:

- `apps/auth/vite.config.ts`
- `apps/org-next/vite.config.ts`
- `apps/public-pages/vite.config.ts`
- `apps/storybook/.storybook/main.ts` (via `viteFinal`)

**Note:** TanStack Start templates currently have a [known issue](https://github.com/TanStack/cli/issues/273) with `vite-tsconfig-paths@^6.0.2`. If switching to built-in support, this issue becomes moot. Otherwise, leave as-is for now and address separately.

### 6. Verify ecosystem plugin compatibility

These plugins need to support Vite 8:

| Plugin | Current version | Vite 8 status |
|--------|----------------|---------------|
| `@cloudflare/vite-plugin` | `^1.26.1` | Likely compatible (check changelog) |
| `@tailwindcss/vite` | `^4.1.18` | Likely compatible (Tailwind v4 is actively maintained) |
| `@tanstack/react-start` + router plugin | `^1.159.5` | Reported issues exist; check latest release |
| `@storybook/react-vite` | `9.0.18` | Vite 8 support merged; needs `>=9.1.x` for peer dep |
| `nitro` (nightly) | `3.0.1-nightly` | Check latest nightly compatibility |
| `@tanstack/devtools-vite` | `^0.3.11` | Check latest release |

### 7. Run `pnpm install` and fix lockfile

After all `package.json` and catalog changes, run `pnpm install` to regenerate the lockfile.

### 8. Build and test each app

Run the full validation suite:

```bash
pnpm run validate
```

Pay special attention to:
- **CJS interop changes**: If any app imports from a CJS-only package, the `default` import behavior may change. Watch for `undefined` default imports at runtime.
- **CSS minification**: Vite 8 uses Lightning CSS by default. Check for visual regressions in production builds.
- **Dev server**: Test HMR on each app, especially the WSS-based HMR setups (builder, org, donor).

### 9. Test SSR apps specifically

The TanStack Start apps (auth, org-next, public-pages) run SSR via Nitro or Cloudflare Workers. These are the highest-risk apps for this migration:
- Test auth's Cloudflare Workers deployment (`@cloudflare/vite-plugin`)
- Test org-next and public-pages with their Nitro integration
- Verify `optimizeDeps.exclude` lists for `msw` and TanStack packages still work correctly

## Risk Assessment

- **Low risk**: builder, org, donor, prototype-org-next (simple SPA configs, already using Rolldown experimentally)
- **Medium risk**: storybook (Storybook 9 needs a version bump for Vite 8 peer dep)
- **Higher risk**: auth, org-next, public-pages (SSR + Nitro/Cloudflare + more complex plugin stacks)

## Recommended Order

1. Catalog bumps (vite, vitest, vitest companions)
2. Remove `experimental.enableNativePlugin` from 3 apps
3. Bump `@vitejs/plugin-react` across all apps
4. `pnpm install`
5. Test low-risk SPA apps first (builder, org, donor, prototype-org-next)
6. Test storybook (bump `@storybook/react-vite` if needed)
7. Test SSR apps (auth, org-next, public-pages)
8. Optionally replace `vite-tsconfig-paths` with built-in `resolve.tsconfigPaths`
9. Full `pnpm run validate`
