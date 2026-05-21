---
name: Harden e2e test reliability
overview: Fix the actual interference/bugs causing flake in `turbo e2e`, keep `vite dev` locally, and make apps run serially under turbo so tests stop competing for CPU — without leaning on larger timeouts as the fix.
todos:
  - id: serial-turbo
    content: Update root `package.json` `e2e` script to `turbo e2e --concurrency=1`.
    status: completed
  - id: fix-timeouts
    content: "Fix timeout inversion in public-pages + auth playwright configs; add `retries` and `trace: retain-on-failure` to all three."
    status: completed
  - id: drop-networkidle
    content: "Replace every `waitForLoadState('networkidle')` / `waitUntil: 'networkidle'` with assertion-based waits in auth + org-next e2e tests."
    status: completed
  - id: fix-reset-race
    content: Refactor `apps/org-next/tests/organizations-new.spec.ts` to pre-register all mocks and remove mid-test `mockServerRequest.reset()` calls.
    status: completed
  - id: hardcode-pp-baseurl
    content: Hard-code `apps/public-pages/playwright.config.ts` `baseUrl` to `http://localhost:3207` instead of reading `VITE_API_HOSTNAME`.
    status: completed
  - id: fix-turbo-inputs
    content: "Clean up `turbo.json` e2e task: remove the sibling `apps/public-pages/**` input and add `.env.e2e` / `.env.test` invalidation."
    status: completed
  - id: port-cleanup
    content: Add a port-kill step to each app's Playwright `webServer.command` (or a `pretest:e2e` script) to recover from zombie processes on 3207/3208/3210.
    status: completed
  - id: fixture-comments
    content: Add short comments in the test fixtures documenting the per-test `MockClient` contract and the no-`reset()`-after-goto rule.
    status: completed
isProject: false
---

## Root causes found

Running `pnpm e2e` (→ `turbo e2e`) today is flaky because of a stack of interacting issues, not one single bug:

1. **Broken timeout invariant.** `apps/public-pages/playwright.config.ts` sets `timeout: 5_000` with `expect.timeout: 10_000`, so a single `toBeVisible()` can legally exceed the whole-test budget. `apps/auth/playwright.config.ts` has the same inversion locally (`timeout: 5_000` / `expect: 5_000`), leaving zero margin. When the machine is loaded, assertions that are *almost* instant still randomly trip the test timeout.
2. **CPU starvation across apps.** `turbo e2e` fans out 3 webServers + `fullyParallel: true` across apps with `workers: 5/5/4` locally → ~14 concurrent Chromium workers + 3 Vite dev servers on one machine. The "timeouts on different tests each run" shape is the classic signature of non-deterministic CPU contention.
3. **`networkidle` + `vite dev` is inherently flaky.** `apps/auth/tests/integration/*.spec.ts` and several `apps/org-next/tests/*.spec.ts` call `page.waitForLoadState("networkidle")` and `page.goto(..., { waitUntil: "networkidle" })`. With HMR websockets and on-demand module transforms, the network is never idle for long windows, so these waits pass or fail stochastically.
4. **`mockServerRequest.reset()` race after navigation.** `apps/org-next/tests/organizations-new.spec.ts` calls `mockServerRequest.reset()` *mid-test* (lines 40 and 76). The adjacent file already documents this as a known race: `apps/org-next/tests/campaigns.spec.ts` line 76 says *"Avoid reset() after load — it clears all handlers while the app can still issue server requests and races RMP header sync."*
5. **Cache/input miswiring in turbo.** `turbo.json` has `"inputs": ["../../apps/public-pages/**"]` on the `e2e` task — a sibling path from whichever app runs the task. It ties every e2e task's cache to `public-pages` and omits each app's own `.env.e2e` from invalidation, so e2e can run against stale caches.
6. **Env bleed into baseURL.** `apps/public-pages/playwright.config.ts` computes `const baseUrl = process.env.VITE_API_HOSTNAME ?? "http://localhost:3207"`. `VITE_API_HOSTNAME` is in `turbo.json#globalEnv`, so an inherited shell value (or another app's `.env.e2e`) silently reroutes the baseURL.
7. **Zombie-port failure mode.** All three configs set `reuseExistingServer: false` and Vite sets `strictPort: true`. If a prior run left a process on 3207/3208/3210 (crash, Ctrl-C), the next run hard-fails on startup rather than starting cleanly.
8. **Retries disabled.** `retries: 0` in all three configs means the last 1% of infrastructure flake is never absorbed.

RMP isolation itself is fine: each test gets its own `MockClient` and the schema travels per-request via the `x-mock-request` header, not server state. Cross-test interference inside a project is not coming from RMP.

## Changes

### 1. Fix `turbo e2e` to run apps serially (root)

Update `package.json` script:

```diff
-"e2e": "turbo e2e",
+"e2e": "turbo e2e --concurrency=1",
```

This is the biggest single reliability win: only one app's webServer + workers runs at a time, eliminating cross-app CPU/Vite/disk contention.

### 2. Fix the timeout inversion (minimal bump, not a blanket raise)

- [apps/public-pages/playwright.config.ts](apps/public-pages/playwright.config.ts): change `timeout: 5_000` → `timeout: 15_000` (still fast; must be ≥ `expect.timeout`).
- [apps/auth/playwright.config.ts](apps/auth/playwright.config.ts): change local `timeout: 5_000` → `15_000`; keep CI at `20_000`. Keep `expect.timeout: 5_000` locally (current). Leave `apps/org-next/playwright.config.ts` (already 20_000) alone.
- Add `retries: process.env.CI ? 2 : 1` to all three configs to absorb the final bit of environmental flake.
- Switch `trace: "off"` → `trace: "retain-on-failure"` so when something does flake we can actually see why.

### 3. Remove `networkidle` waits

Replace every `page.waitForLoadState("networkidle")` and `waitUntil: "networkidle"` with an assertion-based wait on concrete UI the test is about to interact with.

- [apps/auth/tests/integration/sign-in.spec.ts](apps/auth/tests/integration/sign-in.spec.ts): the `page.waitForLoadState("networkidle")` inside `startSignIn` (and direct call at line 12) — assert on the visible heading / input instead (e.g. `await expect(page.getByLabel("Email")).toBeVisible()`).
- [apps/auth/tests/integration/helpers.ts](apps/auth/tests/integration/helpers.ts): drop the `networkidle` in `startSignIn`.
- [apps/auth/tests/integration/challenges.spec.ts](apps/auth/tests/integration/challenges.spec.ts): five `waitForLoadState("networkidle")` calls → assert on the next visible element.
- [apps/org-next/tests/campaigns.spec.ts](apps/org-next/tests/campaigns.spec.ts), [apps/org-next/tests/app-sidebar.spec.ts](apps/org-next/tests/app-sidebar.spec.ts), [apps/org-next/tests/organizations-new.spec.ts](apps/org-next/tests/organizations-new.spec.ts), [apps/org-next/tests/homepage.spec.ts](apps/org-next/tests/homepage.spec.ts): replace `{ waitUntil: "networkidle" }` with default `waitUntil: "load"` (or omit) since every test immediately `expect(...).toBeVisible()` which already waits.

This is both faster and more deterministic.

### 4. Fix the real bug in organizations-new

[apps/org-next/tests/organizations-new.spec.ts](apps/org-next/tests/organizations-new.spec.ts) calls `mockServerRequest.reset()` after the page has loaded and is still issuing server requests — exactly the race called out in `campaigns.spec.ts`. Refactor both tests to register every mock up front (both "before create" and "after create" responses) without a mid-test `reset()`. Matchers are method+URL specific, so pre-registering the POST response plus the post-create `GET /tenants` / `GET /campaigns?tenant_id=...` list does not conflict with the pre-create list mock.

### 5. Remove env bleed on `public-pages` baseURL

[apps/public-pages/playwright.config.ts](apps/public-pages/playwright.config.ts):

```diff
-const baseUrl = process.env.VITE_API_HOSTNAME ?? "http://localhost:3207";
+const baseUrl = "http://localhost:3207";
```

The webServer runs the app on 3207; the Playwright baseURL should not be re-derivable from an env var that is also consumed by the app itself.

### 6. Clean up turbo caching for e2e

[turbo.json](turbo.json):
- Remove `"inputs": ["../../apps/public-pages/**"]` from the `e2e` task.
- Add `.env.e2e` and `.env.test` to `globalDependencies` (or per-task inputs) so env edits invalidate the cache.

### 7. Make the webServer self-recover from zombie ports

For each Playwright config, prefix the `webServer.command` with a port-kill step (uses `lsof -ti` on macOS/Linux and no-ops on Windows CI if relevant). Example for org-next:

```ts
command: `lsof -ti :3210 | xargs -r kill -9 ; ${process.env.CI ? "pnpm exec vite build --mode e2e && pnpm exec vite preview --port 3210" : "pnpm exec vite dev --port 3210 --mode e2e"}`
```

Alternative: add a `pretest:e2e` script per app that does the same cleanup before `playwright test` starts. Either way, a prior-crashed server stops being a flake source.

### 8. Keep RMP fixture assumptions documented

Add one-line comments in [apps/org-next/tests/test-fixture.ts](apps/org-next/tests/test-fixture.ts) and [apps/public-pages/tests/integration/lead.spec.ts](apps/public-pages/tests/integration/lead.spec.ts) that `MockClient` instances must be created per-test (current behavior) and never reset after `page.goto()`. This captures the hard-won constraint so future contributors don't regress it.

## Expected outcome

With (1) serial apps, (3) no `networkidle`, and (4) no mid-test `reset()`, the structural flake sources are gone. (2) only widens a clearly broken margin. (5)-(7) close the remaining tail of environmental flakes.