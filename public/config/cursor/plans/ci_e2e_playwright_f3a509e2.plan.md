---
name: CI E2E Playwright
overview: The monorepo already defines `pnpm e2e` (Turbo runs Playwright in `auth`, `org-next`, and `public-pages` with `--concurrency=1`), but [.github/workflows/test.yml](.github/workflows/test.yml) only runs `pnpm test`. Add browser installation and an e2e step (plus small config hardening for CI).
todos:
  - id: workflow-e2e
    content: Add Playwright browser install, `pnpm e2e`, timeout, and optional artifact upload to `.github/workflows/test.yml`
    status: pending
  - id: org-next-reporter
    content: Set org-next HTML reporter `open` to `never` when `CI` is set
    status: pending
  - id: branch-triggers
    content: Confirm default branch (main vs master) and align workflow `on:` branches if needed
    status: pending
isProject: false
---

# Run E2E tests in GitHub Actions

## Current state

- Root [`package.json`](package.json): `"e2e": "turbo e2e --concurrency=1"`.
- [`turbo.json`](turbo.json): `e2e` depends on `^build` and declares outputs under `playwright-report/**` and `test-results/**`.
- Playwright apps: [`apps/auth`](apps/auth), [`apps/org-next`](apps/org-next), [`apps/public-pages`](apps/public-pages) — each has `e2e` and committed env files ([`apps/auth/.env.test`](apps/auth/.env.test), [`apps/org-next/.env.e2e`](apps/org-next/.env.e2e), [`apps/public-pages/.env.e2e`](apps/public-pages/.env.e2e)).
- [`test.yml`](.github/workflows/test.yml) runs `pnpm install` and `pnpm test` only — **no Playwright browsers, no `pnpm e2e`**.
- [`test-storybook.yml`](.github/workflows/test-storybook.yml) already runs `pnpm exec playwright install chromium` in `apps/storybook` (pattern to mirror).

## Recommended implementation

### 1. Extend the existing Test workflow

In [`.github/workflows/test.yml`](.github/workflows/test.yml), after `pnpm install` and the unit-test step:

1. **Install Chromium + OS deps** (Ubuntu runners need `--with-deps` for headless Chromium), using a workspace that already depends on `@playwright/test`, e.g.:

   `pnpm --filter auth exec playwright install chromium --with-deps`

   (Any of `auth` / `org-next` / `public-pages` is fine; they share the catalog Playwright version.)

2. **Run E2E**: `pnpm e2e`  
   GitHub Actions sets `CI=true` automatically, which matches existing config branches (e.g. auth CI port `3218`, preview builds in [`apps/org-next/playwright.config.ts`](apps/org-next/playwright.config.ts) / [`apps/public-pages/playwright.config.ts`](apps/public-pages/playwright.config.ts)).

3. **Job timeout**: Set `timeout-minutes` on the job (e.g. 30–45) so hung Playwright/webServer runs do not block the queue indefinitely (similar to storybook’s 30).

4. **Artifacts (optional but valuable)**: On failure (or `!cancelled()`), upload reports/traces from all three apps, e.g. `apps/*/playwright-report`, `apps/*/test-results`, so failures are debuggable without reproducing locally.

### 2. Small Playwright config fix for CI (org-next)

[`apps/org-next/playwright.config.ts`](apps/org-next/playwright.config.ts) sets the HTML reporter to `open: "always"`. On CI this can try to open a browser where none exists. Prefer `open: process.env.CI ? "never" : "always"` (or `PLAYWRIGHT_HTML_OPEN=never` in the workflow only). Aligning in config keeps local DX and avoids workflow-only env coupling.

### 3. Verify branch triggers (repo hygiene)

`origin/HEAD` points at **`master`**, while [`test.yml`](.github/workflows/test.yml) triggers on **`main`**. Confirm which branch is actually used for PRs; if the default is `master`, update `on.pull_request` / `on.push` branches so CI runs on the real default (this may explain missing checks today).

## What we are not changing

- No new third-party actions required beyond existing checkout/setup-node/pnpm/cache patterns.
- Keep `pnpm e2e` as the single entrypoint (already matches [`README.md`](README.md) “Quality Standards”).
- No need to duplicate `pnpm build` before `pnpm e2e` beyond what Turbo’s `e2e` → `^build` already does.

## Verification

After implementation, open a PR (or push) and confirm the workflow runs `pnpm e2e` and all three packages’ Playwright suites pass; if anything fails, use uploaded artifacts and traces to triage.
