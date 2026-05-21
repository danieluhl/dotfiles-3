---
name: Fix Auth Test Env
overview: Investigate and fix the auth test failures caused by mock/local-dev environment flags being used with a production-built Playwright preview server.
todos:
  - id: reproduce-failures
    content: After approval, run auth unit and e2e tests with mise to capture the current failing surface.
    status: pending
  - id: add-e2e-env-gate
    content: Add a narrowly scoped e2e-only bypass for local-dev/mock auth in production preview tests.
    status: pending
  - id: normalize-test-env
    content: Clean up `.env.test`/Playwright mock flags so tests use one canonical local-dev flag.
    status: pending
  - id: cover-env-guard
    content: Add unit tests around production guard behavior and the e2e-only allowance.
    status: pending
  - id: validate-fix
    content: Run auth test and e2e commands, then broaden to the full validation gate if needed.
    status: pending
isProject: false
---

# Fix Auth Test Env Failures

## Findings

I could not run the suite in the current Plan-mode session because switching to Agent mode was rejected, and test runs can write build/test artifacts. From the previous single e2e run plus read-only inspection, the likely shared failure is clear.

The e2e runner in [`/Users/duhl/git/ui/apps/auth/playwright.config.ts`](/Users/duhl/git/ui/apps/auth/playwright.config.ts) loads `.env.test`, then starts a production preview build while forcing local-dev auth:

```ts
const previewCommand = `${killPortCommand} && pnpm build && pnpm exec vite preview --port ${port} --strictPort`;
// ...
env: {
  ...process.env,
  ANEDOT_LOCAL_DEV: "true",
}
```

The runtime guard in [`/Users/duhl/git/ui/apps/auth/src/lib/env.ts`](/Users/duhl/git/ui/apps/auth/src/lib/env.ts) rejects that combination:

```ts
if (process.env.NODE_ENV === "production" && process.env[flagName] === "true") {
  throw new Error(`${flagName} cannot be enabled in production`);
}
```

The masked env comparison shows `.env.test` itself has the right app-mode test registry: `test-app` exists, `TEST_APP_SECRET` exists, and the registry references it. The conflict is mode-level: `.env.test` enables mock auth via `VITE_AUTH_MOCK_MODE=true`, and Playwright also forces `ANEDOT_LOCAL_DEV=true`, while `vite preview` is serving a production build.

## Proposed Fix

Keep the production safety guard, but add an explicit test-runtime escape hatch for Playwright production-preview tests. This preserves the deployed-production invariant while allowing e2e to run against a built app with deterministic mock auth.

1. Add a narrowly named test flag, for example `AUTH_E2E_ALLOW_LOCAL_DEV=true`, only in the Playwright web server env and `.env.test` if needed.
2. Update [`/Users/duhl/git/ui/apps/auth/src/lib/env.ts`](/Users/duhl/git/ui/apps/auth/src/lib/env.ts) so `ANEDOT_LOCAL_DEV` / `VITE_AUTH_MOCK_MODE` are still rejected in production unless this e2e-only flag is present.
3. Normalize the e2e mock flag setup in [`/Users/duhl/git/ui/apps/auth/playwright.config.ts`](/Users/duhl/git/ui/apps/auth/playwright.config.ts): either rely on `ANEDOT_LOCAL_DEV=true` and remove the legacy `VITE_AUTH_MOCK_MODE=true` from `.env.test`, or keep both temporarily but make the intent explicit. I would prefer using only `ANEDOT_LOCAL_DEV=true` because the README marks `VITE_AUTH_MOCK_MODE` as legacy.
4. Add focused unit coverage in [`/Users/duhl/git/ui/apps/auth/src/lib/env.test.ts`](/Users/duhl/git/ui/apps/auth/src/lib/env.test.ts):
   - production still rejects `ANEDOT_LOCAL_DEV=true` by default
   - production still rejects `VITE_AUTH_MOCK_MODE=true` by default
   - e2e test mode allows the mock flag without requiring secure cookie production settings
5. Re-run the relevant checks with the repo toolchain:
   - `mise exec -- pnpm --filter auth test`
   - `mise exec -- pnpm --filter auth e2e`
   - if those pass, optionally `mise exec -- pnpm run validate` for the full gate

## Risk Notes

The main risk is accidentally weakening the production guard. The escape hatch should have an explicit e2e/test name, should not be documented as a production option, and should be covered by tests that prove production still fails fast without it.