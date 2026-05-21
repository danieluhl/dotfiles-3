---
name: fix-public-pages-e2e-from-root
overview: Drop `--mode=test` from public-pages and align `.env.e2e` loading across public-pages and org-next so both apps' e2e env vars load reliably.
todos:
  - id: align-mode-e2e
    content: Switch apps/public-pages/playwright.config.ts webServer.command to `--mode e2e` (dev and CI) so Vite auto-loads `.env.e2e`, matching apps/org-next
    status: completed
  - id: dotenv-override
    content: "Add `override: true` to dotenv.config in apps/public-pages/playwright.config.ts (matching org-next) so `.env.e2e` wins over any stale shell env"
    status: completed
  - id: simplify-webServerEnv
    content: Replace the hard-coded VITE_API_HOSTNAME / VITE_ENABLE_RMP in apps/public-pages/playwright.config.ts webServerEnv with a plain spread of process.env, so `.env.e2e` is the single source of truth
    status: completed
  - id: align-env-e2e-values
    content: Ensure apps/public-pages/.env.e2e has the values the config relies on (VITE_API_HOSTNAME=http://localhost:3207, VITE_ENABLE_RMP=true)
    status: completed
  - id: verify-orgnext-env
    content: Confirm apps/org-next already loads .env.e2e correctly under `--mode e2e` (dotenv + native Vite); no code changes expected
    status: completed
  - id: verify-runs
    content: Run `pnpm e2e` from apps/public-pages and `pnpm run e2e` from the monorepo root to confirm env loading is correct and both green
    status: completed
isProject: false
---

# Drop `--mode=test`; load `.env.e2e` in public-pages and org-next

## Context

- [apps/public-pages/playwright.config.ts](apps/public-pages/playwright.config.ts) currently launches `pnpm dev -- --mode=test`. Vite looks for `.env.test` (which no longer exists); the two VITE_* vars survive only because `webServerEnv` re-injects them.
- [apps/org-next/playwright.config.ts](apps/org-next/playwright.config.ts) already uses `--mode e2e` in dev and CI, plus `dotenv.config({ path: ".env.e2e", override: true })`. Vite natively auto-loads `.env.e2e` because the mode name matches the file suffix. This is the working reference.

## Target end-state

Both apps load their own `.env.e2e` from two reinforcing sources:

1. `dotenv` in `playwright.config.ts` loads `.env.e2e` into `process.env` (for the playwright node process and `webServerEnv`).
2. Vite's built-in loader also reads `.env.e2e` via `--mode e2e` (for `import.meta.env.*` and the dev/preview server).

No code references `--mode=test`; Vite auto-loading does the right thing in both apps.

## Changes

### 1. `apps/public-pages/playwright.config.ts`

- Add `override: true` to the dotenv call so stale shell env doesn't win over `.env.e2e`:

  ```ts
  dotenv.config({
    path: path.resolve(configDirectory, ".env.e2e"),
    override: true,
  });
  ```

- Drop `--mode=test`; use `--mode e2e` in both dev and CI so Vite auto-loads `.env.e2e`:

  ```ts
  webServer: {
    command: process.env.CI
      ? "pnpm exec vite build --mode e2e && pnpm exec vite preview --port 3207"
      : "pnpm exec vite dev --port 3207 --mode e2e",
    env: webServerEnv,
    url: readinessUrl,
    reuseExistingServer: !process.env.CI,
    stdout: "pipe",
    stderr: "pipe",
  },
  ```

- Simplify `webServerEnv` so `.env.e2e` is the single source of truth (no inline `VITE_API_HOSTNAME` / `VITE_ENABLE_RMP` overrides):

  ```ts
  const webServerEnv = Object.fromEntries(
    Object.entries(process.env).filter(
      (entry): entry is [string, string] => entry[1] !== undefined,
    ),
  );
  ```

  Remove the now-unused `ciBaseUrl`/`localBaseUrl` branching if `VITE_API_HOSTNAME` in `.env.e2e` is sufficient. `baseUrl` used for Playwright's `use.baseURL` can be derived from `process.env.VITE_API_HOSTNAME` (with a literal fallback for safety).

### 2. `apps/public-pages/.env.e2e`

- Make sure the file exposes everything the config and client bundle need:

  ```
  VITE_API_HOSTNAME=http://localhost:3207
  VITE_ENABLE_RMP=true
  ```

  Note: include the `http://` prefix since the port-only form relied on `prepend-http` in [getApiHostname.ts](packages/api-client/src/utils/getApiHostname.ts), and the hard-coded `webServerEnv` override that previously set the scheme is being removed.

### 3. `apps/org-next/playwright.config.ts` (verification only)

- No changes expected. Current file already: (a) dotenv-loads `.env.e2e` with `override: true`, (b) runs `vite dev/preview --mode e2e`. Confirm `import.meta.env.VITE_*` readers in [apps/org-next/src/env.ts](apps/org-next/src/env.ts) still validate successfully under the run.

## Verification

- From `apps/public-pages`: `pnpm e2e` → still 10/10 green.
- From repo root: `pnpm run e2e` → public-pages 10/10 green, org-next 8/8 green. This also confirms env loading under turbo fan-out.
- Quick sanity: in a transient log or a throwaway `console.log` during the run, confirm `process.env.VITE_API_HOSTNAME`, `process.env.VITE_ENABLE_RMP` are present inside the Vite dev process for both apps, and remove the log.

## Out of scope for this change

The earlier timeout / prewarm / CI-workflow items from the previous plan are intentionally deferred; this change focuses narrowly on env-loading cleanup per the user's direction. A follow-up can address the cold-start timeout separately.
