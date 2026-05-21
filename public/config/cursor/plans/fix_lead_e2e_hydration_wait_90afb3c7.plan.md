---
name: Fix lead e2e hydration wait
overview: The failure means the client never finished mounting the root shell (where `__HYDRATED__` is set) within the 5s local test budget. The most likely causes are a misconfigured or reused dev server without e2e/RMP mode, cold Vite SSR compile under parallel tests, or an overly tight Playwright timeout—not necessarily a bug in the lead route itself.
todos:
  - id: reuse-existing-server-false
    content: "Set `reuseExistingServer: false` in every Playwright config (public-pages + org-next; auth already false) so local runs always spawn the webServer command"
    status: completed
  - id: verify-server
    content: Document or README note—free the app e2e port before running tests (no stray `vite dev` on same port)
    status: completed
  - id: inspect-artifacts
    content: Review Playwright error-context.md + video for blank page, Vite error overlay, or console errors
    status: completed
  - id: adjust-timeouts
    content: Increase local integration test timeout (playwright.config and/or describe.configure) and optionally waitForFunction timeout
    status: completed
  - id: simplify-wait
    content: "Optional: drop or replace __HYDRATED__ wait with load state + heading visibility"
    status: completed
  - id: deep-rmp
    content: "Only if still failing: trace SSR fetch + x-mock-request; consider explicit RMP header forwarding for api-client"
    status: cancelled
isProject: false
---

# Fix `lead.spec.ts` `__HYDRATED__` timeout

## What is actually failing

`gotoLeadPage` waits for `window.__HYDRATED__`, which is assigned only in a client `useEffect` on the root shell:

```48:51:apps/public-pages/src/routes/__root.tsx
function RootDocument({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    window.__HYDRATED__ = true;
  }, []);
```

So Playwright’s error means: **within the test’s 5s budget (local, non-CI)**, either React never hydrated the shell, or hydration took longer than the whole test allows. [`playwright.config.ts`](apps/public-pages/playwright.config.ts) sets `timeout: process.env.CI ? 20_000 : 5_000`, which is aggressive for `vite dev` + first-hit SSR compilation + `workers: 5`.

The lead route loader uses React Query + `getApiClient` (axios → fetch adapter when RMP runs) to load the action page; that path is covered by [`router.tsx`](apps/public-pages/src/router.tsx) SSR setup and [`packages/test-utils/src/request-mocking.ts`](packages/test-utils/src/request-mocking.ts). If SSR fails hard, you can get a response that never completes client startup—but the same symptoms appear if the **browser never runs the app JS** (wrong server, blocked critical request, or timeout before bundle executes).

## Likely root causes (check in this order)

1. **Reused dev server on the e2e port without e2e/RMP**  
   [`apps/public-pages/playwright.config.ts`](apps/public-pages/playwright.config.ts) and [`apps/org-next/playwright.config.ts`](apps/org-next/playwright.config.ts) currently use `reuseExistingServer: !process.env.CI`. If something is already bound to that port from a normal `vite dev` (not `--mode e2e`), Playwright will **not** start the correct web server. **Plan:** set `reuseExistingServer: false` everywhere ([`apps/auth/playwright.config.ts`](apps/auth/playwright.config.ts) is already `false`).

2. **Cold compile + 5s test timeout + parallelism**  
   First navigation to `/lead/...` can pay a large one-time Vite/Nitro cost. With `workers: 5` and `fullyParallel: true`, several tests can hit that cost together. A **5s** total test timeout is easy to exceed before the client ever runs the root `useEffect`.

3. **Less likely: SSR fetch / RMP edge case**  
   RMP relies on `getRequestHeaders()` from [`@tanstack/start-server-core`](node_modules/@tanstack/start-server-core/src/request-response.ts) during intercepted `fetch`. If that ever diverged from the loader’s execution context, mocks would not apply. The codebase already mirrors org-next’s pattern (SSR-only `setupRequestMocking` + axios `adapter = "fetch"` in [`router.tsx`](apps/public-pages/src/router.tsx)). Treat this as secondary until (1) and (2) are ruled out.

## Recommended direction

**A. Confirm environment (no code)**

- After `reuseExistingServer: false`, ensure nothing else is listening on the app’s e2e port before e2e: public-pages [**3207**](apps/public-pages/playwright.config.ts), org-next [**3210**](apps/org-next/playwright.config.ts), auth [**3208** local / **3218** CI](apps/auth/playwright.config.ts).
- From [`apps/public-pages`](apps/public-pages), a manual server for comparison should be `pnpm exec vite dev --port 3207 --mode e2e` so Vite loads [`.env.e2e`](apps/public-pages/.env.e2e) (`VITE_ENABLE_RMP=true`).
- Inspect the failing artifact: `test-results/integration-lead-shows-the-heading-chromium/error-context.md` and the retained video for blank page, error overlay, or stuck loading.

**B. Harden Playwright timing (small, high-value change)**

- Raise the **local** `timeout` in [`playwright.config.ts`](apps/public-pages/playwright.config.ts) to match CI (e.g. 20s) or add `test.describe.configure({ timeout: 20_000 })` only under `tests/integration/`. This directly addresses cold-start flakiness without changing app code.
- Optionally pass an explicit `{ timeout: … }` to `page.waitForFunction` if you keep the `__HYDRATED__` gate.

**C. Reduce coupling to `__HYDRATED__` (optional cleanup)**

- The integration tests already assert visible UI (e.g. the `"Join the Movement"` heading). The `__HYDRATED__` wait is an implementation detail; you can **`page.goto` with `waitUntil: "load"`** (or rely on `expect(...).toBeVisible()`’s retry) and remove the extra gate, or replace it with waiting for a **route-specific** selector. This avoids debugging a flag that does not distinguish “slow” from “broken” any better than the user-visible assertion.

**D. If A–C don’t fix it: prove SSR mock path**

- Add a one-off log or breakpoint in SSR for the lead loader to confirm `x-mock-request` is present on the incoming document request when Playwright sets `context.setExtraHTTPHeaders` via [`MockClient`](apps/public-pages/tests/integration/lead.spec.ts).
- Only if mocks are not applied, consider an org-next-style explicit forward of the RMP header on outbound API calls (public-pages currently depends on the fetch interceptor + ALS, unlike [`forwardRmpMockHeader`](apps/org-next/src/server/org-api.server.ts) for org API).

## `reuseExistingServer` — decided: `false` globally

**Implementation:** Set `reuseExistingServer: false` in [`apps/public-pages/playwright.config.ts`](apps/public-pages/playwright.config.ts) and [`apps/org-next/playwright.config.ts`](apps/org-next/playwright.config.ts). Leave [`apps/auth/playwright.config.ts`](apps/auth/playwright.config.ts) as-is (already `false`). This matches CI behavior for all environments: Playwright always runs the configured `webServer` command so local runs never attach to a mismatched process on the same port.

**Team impact (unchanged tradeoffs):**

- Free the e2e port before running tests, or expect bind failures.
- Pay Vite/preview cold start per suite run (mitigated by `webServer` readiness wait).
- Optional: add a one-line note to [`apps/public-pages/README.md`](apps/public-pages/README.md) (and org-next/auth if they have similar docs) about not running a second dev server on the e2e port.

## Summary

Apply **`reuseExistingServer: false` globally** in Playwright configs; widen local **test timeouts** where needed; ensure dev server command stays `vite … --mode e2e` for apps that use RMP. Only escalate to RMP/ALS deep-dives if failures persist after that.
