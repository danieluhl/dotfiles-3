---
name: Playwright RMP env guard
overview: Add a fail-fast check when Playwright runs so misconfigured `VITE_ENABLE_RMP` stops the run immediately with a clear message pointing at [`apps/org-next/.env.e2e`](apps/org-next/.env.e2e), without changing the underlying fix (keeping RMP enabled there).
todos:
  - id: align-stringbool
    content: Confirm @t3-oss/env-core stringbool accepted values; mirror in playwright assert
    status: completed
  - id: playwright-assert
    content: Add post-dotenv assert + Error message in apps/org-next/playwright.config.ts
    status: completed
  - id: docs-guard
    content: One bullet in apps/org-next/docs/README.md about e2e fail-fast if RMP off
    status: completed
  - id: verify-e2e
    content: Run pnpm e2e (and optional false toggle) to verify behavior
    status: completed
isProject: false
---

# Playwright guard for `VITE_ENABLE_RMP`

## Goal

When someone runs `pnpm e2e` (or any Playwright invocation that uses [`playwright.config.ts`](apps/org-next/playwright.config.ts)), validate that **`VITE_ENABLE_RMP` is enabled** after the same dotenv load the config already uses (`testEnvPath` → [`.env.e2e`](apps/org-next/.env.e2e)). If not, **throw before** the `webServer` command starts, with an error that tells developers to set `VITE_ENABLE_RMP=true` in **`.env.e2e`** (per your choice to keep that filename).

This does not “fix” silent mock bypass by flipping the flag in git; it ensures future misconfiguration surfaces immediately with an actionable message.

## Implementation

1. **Assert in [`playwright.config.ts`](apps/org-next/playwright.config.ts)** immediately after `dotenv.config({ path: testEnvPath, override: true })` (around lines 9–10):
   - Read `process.env.VITE_ENABLE_RMP`.
   - Treat as enabled only when it matches the same semantics your app uses for `z.stringbool()` (typically explicit `"true"` / `"1"` — verify against `@t3-oss/env-core` `stringbool` behavior so the Playwright check cannot disagree with [`src/env.ts`](apps/org-next/src/env.ts)).
   - If disabled or unset: `throw new Error(...)` with a single, copy-paste friendly message, e.g. that Playwright e2e requires request-mocking on the server and **`VITE_ENABLE_RMP` must be `true` in `apps/org-next/.env.e2e`** (and that CI must set it if not relying on the file).

2. **Optional hardening (same PR or follow-up):** mirror the same condition in [`vite.config.ts`](apps/org-next/vite.config.ts) when `process.env` / mode indicates `e2e`, so `vite dev --mode e2e` or `vite preview` fails fast with the same intent. Only add if you want parity outside Playwright; the user request focused on Playwright.

3. **Docs:** add one short bullet under the existing “Request mocking for tests” (or e2e) section in [`docs/README.md`](apps/org-next/docs/README.md) stating that **`pnpm e2e` fails fast** if `VITE_ENABLE_RMP` is not enabled for the e2e env file — no duplication of the full RMP architecture, just the guardrail.

4. **Sanity check:** run `pnpm run e2e` from `apps/org-next` with mise — expect either pass (if `.env.e2e` has `true`) or the new error (temporarily set `false` to verify message).

## Notes

- **Why here, not only in globalSetup:** Top-level code in `playwright.config.ts` runs when the config module loads, **before** Playwright starts `webServer`, so you avoid a useless server boot on bad env.
- **CI:** ensure `.env.e2e` in repo (or CI env) sets `VITE_ENABLE_RMP=true`; the guard will catch accidental removals.
