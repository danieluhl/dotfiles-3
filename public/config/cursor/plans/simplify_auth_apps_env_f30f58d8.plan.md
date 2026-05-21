---
name: Simplify Auth Apps Env
overview: Refactor the auth app's app-mode registry away from JSON-in-env. `AUTH_APPS` becomes a simple slug list, shared cookie/session settings move to top-level env vars, and `virtual-terminal` is included with local port `3211`.
todos:
  - id: parser-contract
    content: Refactor app registry parsing to comma-separated slugs plus scalar top-level env vars.
    status: completed
  - id: env-templates
    content: Update auth and consumer env templates/test envs for the new contract, including virtual-terminal port 3211.
    status: completed
  - id: tests
    content: Rewrite app integration and token-cookie tests around fixed cookie names and the shared secret env.
    status: completed
  - id: docs
    content: Update maintained auth, org-next, and virtual-terminal docs to describe the simplified env contract.
    status: completed
  - id: validate
    content: Run targeted auth tests and broader validation if appropriate.
    status: completed
isProject: false
---

# Simplify `AUTH_APPS` Env Contract

## Proposed Env Shape

Use simple scalar env vars instead of a JSON registry:

```dotenv
AUTH_APPS=org-next,virtual-terminal
AUTH_APP_SESSION_SECRET=replace-with-at-least-32-characters
AUTH_APP_COOKIE_DOMAIN=
AUTH_APP_ORG_NEXT_ALLOWED_ORIGINS=http://localhost:3210
AUTH_APP_VIRTUAL_TERMINAL_ALLOWED_ORIGINS=http://localhost:3211
```

For production-like deploys, the same shape becomes:

```dotenv
AUTH_APPS=org-next,virtual-terminal
AUTH_APP_SESSION_SECRET=<shared value matching each consuming app SESSION_SECRET>
AUTH_APP_COOKIE_DOMAIN=.anedot.com
AUTH_APP_ORG_NEXT_ALLOWED_ORIGINS=https://org.anedot.com
AUTH_APP_VIRTUAL_TERMINAL_ALLOWED_ORIGINS=https://<virtual-terminal-host>
```

Rules:

- `AUTH_APPS` is a comma-separated slug list, not JSON.
- `AUTH_APP_SESSION_SECRET` is the single auth-side app-cookie/auth-state secret for all app-mode consumers. Each consumer still sets its own local variable as `SESSION_SECRET`, but the value must match this auth-side secret.
- Cookie names are not configurable through env. `authToken`, `refreshToken`, and `idToken` stay as code defaults in [apps/auth/src/lib/app-integration.ts](apps/auth/src/lib/app-integration.ts).
- `AUTH_APP_COOKIE_DOMAIN` is shared across registered apps because the cookie domain is environment-level, not app-level. Blank means host-scoped local cookies.
- Per-app allowed origins use a deterministic env name: `AUTH_APP_<SLUG_IN_UPPER_SNAKE>_ALLOWED_ORIGINS`. Hyphens become underscores, so `virtual-terminal` maps to `AUTH_APP_VIRTUAL_TERMINAL_ALLOWED_ORIGINS`.
- If multiple origins are needed for one app, use a comma-separated value rather than JSON.

## Implementation Plan

1. Update the registry parser in [apps/auth/src/lib/app-integration.ts](apps/auth/src/lib/app-integration.ts).
   - Replace `parseRegistryEnv()` JSON parsing with a comma-list parser for `AUTH_APPS`.
   - Build each `RawAppEntry` from top-level env vars:
     - slug from `AUTH_APPS`
     - allowed origins from `AUTH_APP_<SLUG>_ALLOWED_ORIGINS`
     - cookie domain from `AUTH_APP_COOKIE_DOMAIN`
     - session secret from `AUTH_APP_SESSION_SECRET`
   - Keep the public `AppConfig` shape stable so downstream token-cookie code can remain mostly unchanged.

2. Remove env-configurable cookie names and nested secret env support.
   - Keep `DEFAULT_COOKIE_NAMES` as the only cookie-name source.
   - Remove `cookieNames`, inline `sessionSecret`, and `sessionSecretEnv` from the raw registry contract.
   - Update debug info so it reports the shared `AUTH_APP_SESSION_SECRET` presence/length without exposing the value.

3. Update auth app env examples.
   - Add the new env vars to [apps/auth/.env.template](apps/auth/.env.template).
   - Rewrite [apps/auth/.env.test](apps/auth/.env.test) so `AUTH_APPS` is `test-app,org-next,virtual-terminal` and includes `AUTH_APP_VIRTUAL_TERMINAL_ALLOWED_ORIGINS=http://localhost:3211`.

4. Update tests around the new contract.
   - Rewrite [apps/auth/src/lib/app-integration.test.ts](apps/auth/src/lib/app-integration.test.ts) to cover comma-separated `AUTH_APPS`, missing shared secret, invalid/empty allowed origins, and default cookie names.
   - Update [apps/auth/src/lib/app-integration.org-next.test.ts](apps/auth/src/lib/app-integration.org-next.test.ts) and [apps/auth/src/lib/app-integration.virtual-terminal.test.ts](apps/auth/src/lib/app-integration.virtual-terminal.test.ts) to use `AUTH_APP_SESSION_SECRET` and per-app origin env vars.
   - Update [apps/auth/src/lib/app-token-cookies.test.ts](apps/auth/src/lib/app-token-cookies.test.ts) to remove the custom-cookie-name case.

5. Update maintained docs.
   - Rewrite the registry section in [apps/auth/docs/app-integration.md](apps/auth/docs/app-integration.md) to show the scalar env contract above.
   - Update consumer docs that reference nested JSON paths, especially [apps/virtual-terminal/docs/README.md](apps/virtual-terminal/docs/README.md) and likely [apps/org-next/docs/README.md](apps/org-next/docs/README.md).
   - Update consumer `.env.template` comments in [apps/org-next/.env.template](apps/org-next/.env.template) and [apps/virtual-terminal/.env.template](apps/virtual-terminal/.env.template) so they refer to `AUTH_APP_SESSION_SECRET`, not `AUTH_APPS[...].sessionSecretEnv`.

6. Validate with targeted checks first, then the broader gate if time allows.
   - Run the auth app tests that cover `app-integration` and `app-token-cookies`.
   - Prefer `pnpm run validate` for final confidence if the change is ready for pre-merge verification.

## Acceptance Criteria

- No app-mode auth config requires JSON inside `AUTH_APPS`.
- `virtual-terminal` is present in auth app env examples with `http://localhost:3211` allowed.
- Cookie names are fixed in code and omitted from env/docs examples.
- All app-mode consumers use one shared auth-side `AUTH_APP_SESSION_SECRET` value that matches each consumer's `SESSION_SECRET`.
- Existing app-mode call sites continue to receive an `AppConfig` with `cookieNames`, `cookieDomain`, `allowedOrigins`, and `sessionSecret` populated.