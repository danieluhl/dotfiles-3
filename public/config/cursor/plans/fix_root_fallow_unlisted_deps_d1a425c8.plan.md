---
name: fix root fallow unlisted deps
overview: Stop reporting 12 false-positive unlisted dependencies by removing the cross-workspace `entry` glob from the root fallow config and routing root `pnpm run fallow` through per-workspace runs (so each workspace's package.json is what fallow checks against). Also fix the one genuine finding (`msw`) it surfaces.
todos:
  - id: turbo_task
    content: Add `fallow` task to turbo.json (dependsOn ^build, no outputs)
    status: pending
  - id: root_scripts
    content: Update root package.json `fallow`/`fa` scripts to delegate to `turbo run fallow`
    status: pending
  - id: simplify_root_fallowrc
    content: "Remove `entry: [\"apps/**\"]` and per-workspace `ignorePatterns` from root .fallowrc.json; keep publicPackages, health, and language-level globs"
    status: pending
  - id: track_org_next_fallowrc
    content: Track apps/org-next/.fallowrc.json and gitignore .fallow/cache.bin and .fallow/churn.bin
    status: pending
  - id: fix_msw_unlisted
    content: Add `msw` to apps/org-next/package.json devDependencies (catalog:) to resolve the genuine unlisted finding
    status: pending
  - id: verify
    content: Run `pnpm run fallow` from root and from apps/org-next to confirm 0 unlisted dependencies
    status: pending
isProject: false
---

## Diagnosis recap

`fallow dead-code` from the repo root reports 12 unlisted deps that are all already declared in [apps/org-next/package.json](apps/org-next/package.json) (`rollbar`, `sonner`, `lucide-react`, `zod`, `@tanstack/react-form`, `@tanstack/react-query`, `tw-animate-css`, `@fontsource-variable/outfit`, `@tanstack/react-devtools`, `@tanstack/react-router-ssr-query`, `@tanstack/start-server-core`, `request-mocking-protocol`). The cause is in [.fallowrc.json](.fallowrc.json):

```1:42:.fallowrc.json
{
  "ignorePatterns": [
    "apps/auth/**",
    ...
    "packages/**",
    ...
  ],
  "entry": ["apps/**"],
  ...
}
```

`entry` adds manual entry points owned by the config that declared them. Because `apps/org-next/package.json` has no `main`/`module`/`exports` fields, fallow's per-workspace package.json auto-detection produces zero entries for it. The root `entry: ["apps/**"]` then fills the gap, but those entries are attributed to the root context, so fallow checks the root `package.json` for the imported deps and they aren't there. `fallow list --entry-points` confirms it: every `org-next` source file is tagged `(manual entry)`.

Two pieces of supporting evidence:
- Inside [apps/org-next/](apps/org-next/), `fallow dead-code` (using the local [.fallowrc.json](apps/org-next/.fallowrc.json)) reports only 1 unlisted: `msw` (a real bug — it's imported by [apps/org-next/tests/test-fixture.ts](apps/org-next/tests/test-fixture.ts) but only declared in root `devDependencies`).
- `fallow dead-code -w org-next` from root reports 0 issues, because `-w` re-attributes findings to the workspace whose `package.json` actually owns the deps.

Right now the root config is also gated to org-next only — every other app and all of `packages/**` are in `ignorePatterns`. So a single root run isn't earning much over a per-workspace run.

## Approach

Run fallow per workspace via the existing Turbo pipeline (matches how `lint`, `typecheck`, `test`, `e2e` already work), and remove the cross-workspace `entry` glob that misattributes ownership.

## Changes

1. Add a `fallow` task to [turbo.json](turbo.json) so Turbo can fan out per workspace:

```json
"fallow": {
  "dependsOn": ["^build"],
  "outputs": []
}
```

   `^build` is needed because some workspace `package.json` `exports` point at `dist/`; fallow's logs show the fallback path mapping working, but matching the existing `typecheck`/`test` tasks keeps caching consistent.

2. Replace the root `fallow` scripts in [package.json](package.json) so the root run delegates:

```json
"fallow": "turbo run fallow",
"fa": "turbo run fallow --"
```

3. Simplify [.fallowrc.json](.fallowrc.json) at the repo root so it stops registering cross-workspace entries:
   - Remove `"entry": ["apps/**"]` (per-workspace configs and plugin auto-detection cover this).
   - Remove all `apps/<app>/**` and `packages/**` entries from `ignorePatterns` — they only mattered to scope the root `entry` glob; with per-workspace runs, each workspace decides what it analyzes.
   - Keep `publicPackages`, `health`, and the language-level ignore globs (`**/*.gen.ts`, `**/*.config.ts`, etc.) so they're inherited via `extends` by every workspace `.fallowrc.json`.

4. Make the org-next config first-class instead of untracked:
   - Track [apps/org-next/.fallowrc.json](apps/org-next/.fallowrc.json) (currently `??` in `git status`) so the local `entry: ["src/**/*"]` and zone boundaries are versioned.
   - Add a `.gitignore` rule for `.fallow/cache.bin` and `.fallow/churn.bin` (already present in untracked dirs at repo root and `apps/org-next/`) so those incremental caches stop showing up as new files.

5. For other workspaces that should be analyzed (or explicitly skipped), add a `fallow` script in their `package.json`:
   - Apps you want analyzed: `"fallow": "fallow dead-code && fallow dupes"` plus a local `.fallowrc.json` extending the root.
   - Apps you don't want analyzed yet: omit the script — Turbo will simply skip them. (No need for the old `ignorePatterns` block at the root.)

6. Fix the genuine `msw` finding surfaced by the local org-next run. `msw` is used by [apps/org-next/tests/test-fixture.ts](apps/org-next/tests/test-fixture.ts) but only declared in root `devDependencies`. Either:
   - Add `"msw": "catalog:"` to `devDependencies` in [apps/org-next/package.json](apps/org-next/package.json), or
   - Add `"msw"` to `ignoreDependencies` in the root or org-next `.fallowrc.json` if you intentionally want it hoisted.

   Recommended: add it as a real devDep in org-next so the relationship is explicit.

7. Sanity-check by running:
   - `pnpm run fallow` from the repo root (should now fan out via Turbo and pass).
   - `pnpm --filter org-next run fallow` (should pass after step 6).
   - `pnpm exec fallow list --entry-points` from `apps/org-next/` to confirm entries are now sourced from the workspace's own config / plugins, not from a root manual glob.

## Why not just remove `entry: ["apps/**"]` and keep one root run?

That alone fixes the false positives, but it leaves you with a root config that quietly only analyzes one workspace (everything else is in `ignorePatterns`) — confusing as more apps adopt fallow. Per-workspace runs via Turbo make ownership explicit, give each app its own cache, and match the rest of the build pipeline.