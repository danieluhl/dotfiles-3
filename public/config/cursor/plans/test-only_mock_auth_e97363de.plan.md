---
name: test-only mock auth
overview: Remove the local-development mock authorization path while keeping mock auth available only to automated tests. The implementation will fail closed outside explicit test contexts and update docs/env templates so developers are guided toward Cognito-backed local auth.
todos:
  - id: gate-mock-auth
    content: Make mock auth opt-in through a server-only test flag and explicit test context.
    status: pending
  - id: update-tests
    content: Move auth unit and Playwright tests to the new test-only mock flag.
    status: pending
  - id: clean-docs-env
    content: Remove local mock auth guidance/defaults from docs and env templates.
    status: pending
  - id: verify-no-traces
    content: Search for stale local/mock auth references and run focused validation.
    status: pending
isProject: false
---

# Remove Local Mock Auth Path

## Scope
- Keep mock auth behavior for automated tests only.
- Remove the supported local-development path from docs and default env templates.
- Do not remove app-mode (`app=org-next` / `app=virtual-terminal`) or the classic OAuth contract in this change.

## Implementation Plan
- Replace `VITE_AUTH_MOCK_MODE` with a server-only, test-named flag such as `AUTH_TEST_MOCK_MODE` in [apps/auth/src/lib/env.ts](apps/auth/src/lib/env.ts). Gate it behind an explicit test context so mock mode cannot silently run in normal dev/preview/prod.
- Update auth server code that branches on `isMockAuthEnabled()` in [apps/auth/src/features/auth/server-functions.ts](apps/auth/src/features/auth/server-functions.ts) and [apps/auth/src/lib/session.ts](apps/auth/src/lib/session.ts) to keep the mock paths working only through the new test-only guard.
- Update Playwright/Vitest wiring in [apps/auth/playwright.config.ts](apps/auth/playwright.config.ts), [apps/auth/.env.test](apps/auth/.env.test), [apps/auth/src/lib/env.test.ts](apps/auth/src/lib/env.test.ts), and [apps/auth/src/lib/app-token-cookies.test.ts](apps/auth/src/lib/app-token-cookies.test.ts) to use the new test-only flag and remove assertions that describe production mock/local preview as supported behavior.
- Remove local mock defaults and user-facing guidance from [apps/auth/.env.template](apps/auth/.env.template), [apps/auth/README.md](apps/auth/README.md), and [apps/auth/docs/auth-cookie.md](apps/auth/docs/auth-cookie.md). The docs should say Cognito-backed env is required for local development, while mock auth is reserved for tests.
- Search the repo for stale references to `VITE_AUTH_MOCK_MODE`, “local/mock auth”, and “mock mode” and remove or rewrite any remaining non-test-facing traces.

## Verification
- Run focused checks with the repo toolchain via `mise exec -- pnpm --filter auth test`.
- Run auth E2E with `mise exec -- pnpm --filter auth e2e` to prove the test-only mock path still works.
- If the changes touch generated route/build behavior indirectly, run `mise exec -- pnpm --filter auth build`.

## Risk Notes
- The main risk is accidentally breaking Playwright’s preview server, since it currently uses production-like preview with mock auth enabled. The new gate should be explicit enough for tests but impossible to enable accidentally in ordinary local development.