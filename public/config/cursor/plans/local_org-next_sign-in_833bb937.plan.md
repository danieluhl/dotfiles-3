---
name: Local org-next sign-in
overview: Make auth, org-next, and the anedot_next Rails backend share a single ANEDOT_LOCAL_DEV flag so any login credentials work end-to-end in local dev, and add a root-of-auth-app integration guide for new consumer apps.
todos:
  - id: unify-flag-auth
    content: Introduce ANEDOT_LOCAL_DEV in the auth app and make it the canonical local-dev flag (with a deprecated VITE_AUTH_MOCK_MODE fallback).
    status: completed
  - id: real-shape-jwt
    content: Have the auth app mint a real-shape HS256 JWT (instead of mock-access-<uuid>) signed with LOCAL_DEV_JWT_SECRET when ANEDOT_LOCAL_DEV=true, so the Rails backend can decode it.
    status: completed
  - id: anedot-next-decoder
    content: Update anedot_next CognitoJwtValidator + initializer to switch to HS256 + LOCAL_DEV_JWT_SECRET when ANEDOT_LOCAL_DEV=true and skip JWKS/issuer/client_id checks.
    status: completed
  - id: org-next-flag
    content: Add ANEDOT_LOCAL_DEV=true to apps/org-next/.env.template alongside SESSION_SECRET and document that no functional change is required in org-next.
    status: completed
  - id: env-templates-and-readme
    content: Update apps/auth/.env.template, apps/auth/README.md, anedot_next/.env, and add ANEDOT_LOCAL_DEV / LOCAL_DEV_JWT_SECRET wherever needed.
    status: completed
  - id: integration-doc
    content: Create apps/auth/INTEGRATING.md — a root-of-auth-app guide covering both the integration contract and the local dev quickstart for any new consumer app.
    status: completed
isProject: false
---

# Local development across auth, org-next, and anedot_next

## Goal

A new developer can clone all three repos, set one shared env var, and sign into org-next (or any new consumer app) at `http://localhost:3210` with **any** email + password — including reaching the real Rails API at `http://localhost:3000` — without ever touching Cognito or an emailed verification code. Production behavior is unchanged when the flag is unset.

The plan keeps the existing app-mode integration contract from [apps/auth/docs/app-integration.md](apps/auth/docs/app-integration.md) untouched; it only changes what *kind* of token the auth app mints in local dev and how the Rails backend validates it.

## The unified flag: `ANEDOT_LOCAL_DEV=true`

One name, three apps:

| App | Reads as | Behavior when `true` |
|---|---|---|
| `apps/auth` | `process.env.ANEDOT_LOCAL_DEV` | Skip Cognito on sign-in/up/confirm; mint a real-shape HS256 JWT for the access token; any email+password accepted. |
| `apps/org-next` | `process.env.ANEDOT_LOCAL_DEV` (also exposed via `import.meta.env` if we want a banner) | No functional change — already passes the cookie's bearer through. Optional: render a small "LOCAL DEV" banner. |
| `anedot_next` | `ENV["ANEDOT_LOCAL_DEV"]` | `CognitoJwtValidator` decodes HS256 with `LOCAL_DEV_JWT_SECRET` and skips JWKS / `iss` / `client_id` checks; user lookup-or-create still keys on `sub`/`email`. |

Plus one shared HS256 secret across the auth app and the Rails backend:

```
LOCAL_DEV_JWT_SECRET=<at least 32 chars, identical on auth + anedot_next>
```

Production never sets either variable, so all the new code paths are dead.

## Token shape (the only new contract)

When `ANEDOT_LOCAL_DEV=true`, the auth app issues a JWT in this shape (instead of `mock-access-<uuid>`):

```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

Payload:

```json
{
  "iss": "anedot-local-dev",
  "sub": "local-dev|<email>",
  "email": "<whatever the user typed>",
  "given_name": "Local",
  "family_name": "Dev",
  "token_use": "access",
  "client_id": "anedot-local-dev",
  "iat": <unix>,
  "exp": <unix + 1h>,
  "jti": "<uuid>"
}
```

- HMAC-SHA256 signed with `LOCAL_DEV_JWT_SECRET`.
- `sub` is deterministic per email so re-signing in lands on the same Rails `User` row.
- All claim names match what `CognitoJwtValidator` already checks for in production (`sub`, `email`, `token_use=="access"`, `client_id`), so the validator branches on `ANEDOT_LOCAL_DEV` and reuses the same downstream code.

## Per-app changes

### `apps/auth`

Files to touch:

- [apps/auth/src/lib/env.ts](apps/auth/src/lib/env.ts):
  - Add `isLocalDev()` reading `process.env.ANEDOT_LOCAL_DEV === "true"`.
  - Make `isMockAuthEnabled()` return `isLocalDev() || process.env.VITE_AUTH_MOCK_MODE === "true"` for backward compat (and console.warn the legacy name).
  - Add `getLocalDevJwtSecret()` that throws if `isLocalDev()` and the secret is missing or <32 chars (mirrors `getSessionSecret`).
- New file `apps/auth/src/lib/local-dev-jwt.ts` exporting `signLocalDevAccessToken({ email })`. Reuse the base64url + HMAC patterns already in [bootstrap-jwt.ts](apps/auth/src/lib/bootstrap-jwt.ts).
- [apps/auth/src/features/auth/server-functions.ts](apps/auth/src/features/auth/server-functions.ts):
  - In `submitSignInFn` / `submitConfirmSignUpFn` / `submitChallengeFn`'s mock branches that currently call `setMockAuthCookie` or `redirectToAppReturn`, swap the synthetic `mock-access-<uuid>` for a call into `writeAppTokenCookies(app, { accessToken: signLocalDevAccessToken({ email }), idToken: signLocalDevAccessToken({ email, token_use: "id" }), refreshToken: undefined })` so the cookies the consumer reads now contain a real-shape JWT.
  - Identical change to the OAuth (non-app) mock branch (`setMockAuthCookie`) so old consumers also benefit.
- [apps/auth/.env.template](apps/auth/.env.template): replace `VITE_AUTH_MOCK_MODE=true` with `ANEDOT_LOCAL_DEV=true` and add `LOCAL_DEV_JWT_SECRET=replace-with-at-least-32-characters` next to `AUTH_SESSION_SECRET`. Leave `VITE_AUTH_MOCK_MODE` out (deprecated; fallback still works).
- [apps/auth/README.md](apps/auth/README.md): replace the "Local development" section with one paragraph that points at the new `INTEGRATING.md` for a full step-by-step.
- Tests: rename `VITE_AUTH_MOCK_MODE` → `ANEDOT_LOCAL_DEV` in [apps/auth/.env.test](apps/auth/.env.test) and [apps/auth/playwright.config.ts](apps/auth/playwright.config.ts). No production semantics change.

Touchstone: existing tests in [apps/auth/src/lib/env.test.ts](apps/auth/src/lib/env.test.ts) and `app-integration.org-next.test.ts` should still pass after the `isMockAuthEnabled()` shim, with one new test for `signLocalDevAccessToken`.

### `apps/org-next`

Files to touch (small, mostly env):

- [apps/org-next/.env.template](apps/org-next/.env.template): add `ANEDOT_LOCAL_DEV=true` (commented-out by default with a one-liner explanation). No functional code path needs it today — it exists so the variable is greppable and consistent with the other apps.
- [apps/org-next/src/env.ts](apps/org-next/src/env.ts) (file not yet read; verify): add an optional `ANEDOT_LOCAL_DEV: z.coerce.boolean().default(false)` so we can later light up a "LOCAL DEV" banner without further plumbing.
- [apps/org-next/docs/README.md](apps/org-next/docs/README.md): update the "Auth flow (cross-app)" section to mention the unified flag and link to the new auth-app integration doc.

Explicitly **out of scope** for this plan: any change to org-next's `org-api.server.ts` token forwarding — it already does exactly the right thing by passing the cookie's bearer through.

### `anedot_next` (Rails)

Files to touch:

- [anedot_next/config/initializers/cognito.rb](anedot_next/config/initializers/cognito.rb): extend the `Rails.application.config.cognito` hash with two more keys:

  ```ruby
  local_dev: ENV["ANEDOT_LOCAL_DEV"] == "true",
  local_dev_jwt_secret: ENV["LOCAL_DEV_JWT_SECRET"]
  ```

- [anedot_next/app/services/cognito_jwt_validator.rb](anedot_next/app/services/cognito_jwt_validator.rb): at the top of `#decode`, branch on `@config[:local_dev]`:

  ```ruby
  return decode_local_dev if @config[:local_dev]
  ```

  with `decode_local_dev` doing `JWT.decode(@token, @config[:local_dev_jwt_secret], true, algorithms: ["HS256"], verify_expiration: true)` and asserting `sub` + `email` + `token_use == "access"`. JWKS, `iss`, and `client_id` are skipped.
- `User.find_by(cognito_sub:)` plus `create_user_from_cognito` in [cognito_jwt_authentication.rb](anedot_next/app/controllers/concerns/cognito_jwt_authentication.rb) are already correct for the local-dev path — `sub == "local-dev|<email>"` is just another stable identifier.
- [anedot_next/.env](anedot_next/.env): add `ANEDOT_LOCAL_DEV=true` and `LOCAL_DEV_JWT_SECRET=<paste same value as auth app>` with a comment that they must match the auth app.
- New test in [anedot_next/test/services/cognito_jwt_validator_test.rb](anedot_next/test/services/cognito_jwt_validator_test.rb): one happy-path test that signs an HS256 token with the dev secret, sets `local_dev: true` in config, and asserts it decodes with the right `email`/`sub`.

## End-to-end local dev workflow (what a developer does)

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Browser
    participant OrgNext as org-next:3210
    participant Auth as auth:3208
    participant Rails as anedot_next:3000

    Dev->>OrgNext: pnpm --filter org-next dev
    Dev->>Auth: pnpm --filter auth dev
    Dev->>Rails: bin/rails server (with ANEDOT_LOCAL_DEV=true)
    Browser->>OrgNext: GET /login
    OrgNext-->>Browser: 302 -> auth/authorize?app=org-next
    Browser->>Auth: GET /authorize
    Auth-->>Browser: 302 -> /sign-in
    Browser->>Auth: POST /sign-in (any email + password)
    Auth->>Auth: signLocalDevAccessToken(email)
    Auth-->>Browser: Set-Cookie authToken=<HS256 JWT>; 302 -> org-next/
    Browser->>OrgNext: GET / with authToken cookie
    OrgNext->>Rails: GET /users/me Authorization: Bearer <JWT>
    Rails->>Rails: CognitoJwtValidator (local_dev branch)
    Rails-->>OrgNext: 200 user JSON
    OrgNext-->>Browser: render
```

The developer's checklist:

1. `apps/auth/.env.local` ← copy `.env.template`, set `ANEDOT_LOCAL_DEV=true`, `AUTH_SESSION_SECRET`, `LOCAL_DEV_JWT_SECRET`, `<APP>_SESSION_SECRET`, `AUTH_APPS`.
2. `apps/<your-app>/.env.local` ← `SESSION_SECRET` matching `<APP>_SESSION_SECRET`, `VITE_AUTH_APP_URL=http://localhost:3208`, `ANEDOT_LOCAL_DEV=true`.
3. `anedot_next/.env.development.local` ← `ANEDOT_LOCAL_DEV=true`, `LOCAL_DEV_JWT_SECRET=<same as auth>`.
4. Restart all three dev servers.
5. Hit `http://localhost:3210/login`, type any email/password, you're in.

## The new integration doc: `apps/auth/INTEGRATING.md`

A single root-of-auth-app file that any developer onboarding a new app can read top-to-bottom. Outline:

```
# Integrating a new app with the Anedot Auth app

## TL;DR
- 5-minute checklist
- Link to docs/app-integration.md for the formal contract

## 1. Pick a slug, share a secret
- AUTH_APPS entry shape (copy-paste with placeholders)
- Generate <APP>_SESSION_SECRET, paste into both auth env and your app env
- cookieDomain="" for localhost, ".anedot.com" in prod

## 2. Wire your app's login + logout
- buildAuthAppLoginUrl pattern (link to org-next's src/server/auth-state.ts as the reference impl)
- Sign auth_state with your SESSION_SECRET
- Read the three cookies via TanStack useSession with the same names + secret
- Forward authToken cookie value as Authorization: Bearer to your backend

## 3. Local development with `ANEDOT_LOCAL_DEV=true`
- The unified flag, the three apps that read it, the shared LOCAL_DEV_JWT_SECRET
- Mermaid diagram (same as above)
- Step-by-step env files for auth + your app + anedot_next
- "Any email + any password works" guarantee
- Sign-up / verification code paths also accept any input

## 4. Production deployment
- Drop ANEDOT_LOCAL_DEV; set Cognito creds + cookieDomain=".anedot.com"; share AUTH_APPS / SESSION_SECRET via your secret manager
- Reference the env-var matrix in docs/app-integration.md

## 5. Reference: org-next as the canonical example
- src/routes/login.tsx, src/routes/-auth.ts, src/server/auth-state.ts
- src/server/session.server.ts shows the cookie reader pattern
- src/server/org-api.server.ts shows bearer forwarding
- apps/org-next/docs/README.md "Auth flow (cross-app)" for the integration commentary
```

The doc deliberately does **not** repeat the formal contract from `docs/app-integration.md`; it links to it. It is written as a checklist a developer can execute, with concrete file paths from the org-next reference implementation.

## Out of scope (call out so it doesn't creep in)

- The Playwright `/test-seed/auth` route and `E2E_TEST_SEED` flag stay exactly as they are — separate machinery for tests.
- No "auto sign-in as admin" button on the auth screen. The local-dev flow still goes through the form once; this matches the production UX a developer is debugging.
- No tenant seeding. A first-time local-dev user lands in `/organizations/new` (per `_authed.tsx`) and creates their tenant the normal way; if you need pre-seeded tenants, that's a separate `db:seed` PR on `anedot_next`.
- No production behavior changes. Every new code path is gated on `ANEDOT_LOCAL_DEV` (or its equivalent on the Rails side).
