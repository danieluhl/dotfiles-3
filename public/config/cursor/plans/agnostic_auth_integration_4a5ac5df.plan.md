---
name: agnostic auth integration
overview: "Update the existing org-next/auth wiring plan so the auth app stays agnostic to which client app it serves: a generic \"app integration\" registry drives cookie writing, return_to policy, refresh, and logout. Org-next becomes the first consumer of this generic mode."
todos:
  - id: auth-registry
    content: "Add generic App Integration Registry: AUTH_APPS env parser, AppConfig type, resolveAppConfig, isAllowedReturnTo, sign/verifyAuthState"
    status: completed
  - id: auth-cookie-helpers
    content: "Add app-token-cookies.ts: writeAppTokenCookies / clearAppTokenCookies driven by AppConfig (no app slugs hardcoded)"
    status: completed
  - id: auth-contracts-app-mode
    content: Extend authorizeSearchSchema and logoutSearchSchema to accept generic app/return_to/auth_state mode without breaking existing client_id/redirect_uri/session_url mode
    status: completed
  - id: auth-server-fns-app-mode
    content: Branch beginAuthorizeFn, sign-in/MFA/new-password/confirm-sign-up success, and beginLogoutFn on presence of `app`; never reference specific app slugs
    status: completed
  - id: auth-refresh-endpoint
    content: "Add generic /apps/refresh server function: refresh app's tokens via Cognito, rewrite app cookies, clear+401 on failure"
    status: completed
  - id: org-next-env-cleanup
    content: Remove MOCK_ACCESS_TOKEN, VITE_TEMP_BYPASS_AUTH, VITE_AUTH_CLIENT_ID from env, templates, docs, tests, runtime
    status: completed
  - id: org-next-session-readers
    content: Add useIdTokenSession in session.server.ts; align names/secret with AUTH_APPS org-next entry
    status: completed
  - id: org-next-login-logout
    content: Update -auth.ts to redirect to authorize?app=org-next&return_to=...&auth_state=...; logout to /logout?app=org-next&return_to=/login?logged_out=1
    status: completed
  - id: org-next-org-api-401
    content: Drop MOCK_ACCESS_TOKEN fallback in org-api.server.ts; missing authToken → 401
    status: completed
  - id: backend-jwt-validation
    content: Replace User.last stub in anedot_next with real Cognito JWT validation (token_use=access, signature, iss, exp, client_id, email claim, find/create by cognito_sub)
    status: completed
  - id: auth-tests-generic
    content: Tests for registry, return_to policy, auth_state signing, writeAppTokenCookies, app-mode authorize/sign-in/refresh/logout using a synthetic test-app entry
    status: completed
  - id: auth-tests-org-next-smoke
    content: Single focused integration test verifying the org-next AUTH_APPS entry wires cookie names/origins correctly
    status: completed
  - id: org-next-tests
    content: Tests for login URL construction, auth_state mismatch, original-route restoration, useIdTokenSession, missing-cookie 401 without mock fallback; Playwright fixtures set explicit signed cookies
    status: completed
  - id: backend-tests
    content: "Backend tests: missing token, invalid JWT, wrong token type, missing email, existing user lookup, new user creation"
    status: completed
  - id: docs-app-integration
    content: Add apps/auth/docs/app-integration.md (generic), update apps/auth/docs/spec.md, update apps/org-next/docs/README.md auth section to link to it; leave client-integration.md and session-bootstrap.md untouched
    status: completed
isProject: false
---

# Complete Org-Next/Auth Connection — Generic App Integration Mode

## Summary

Keep the auth app's existing OAuth contract (`client_id`, `redirect_uri`, `session_url`, `/auth-status`, `anedot-auth` cookie, Google/federated paths) untouched for all current external clients.

Introduce a second, generic integration mode in the auth app — "same-domain token cookie" mode — that any modern Anedot app (TanStack Start, etc.) can use without the auth app having any hardcoded knowledge of that app. Org-next is the first consumer; the code paths must not name `org-next` outside of: registry config values, example env, docs, and org-next's own source.

In this mode the auth app writes per-app, app-scoped, signed httpOnly cookies (`authToken`, `refreshToken`, `idToken`) using a per-app cookie config resolved from a registry. The consuming app reads `authToken` for its API calls. Refresh remains auth-owned.

## Agnosticism Principle (new — applies to entire plan)

- The auth app gets a single generic concept: an **App Integration Registry**. Each entry describes one consuming app: slug, allowed origins, return_to policy, cookie names, cookie domain, signing secret, optional Cognito client mapping.
- Every new code path (authorize-app mode, cookie writers, refresh, logout) must take an `AppConfig` argument resolved from the registry. No file outside the registry/env layer should mention specific app slugs.
- The `app` query param is just a registry key. There is no `if (app === "org-next")` branch anywhere.
- Strings like "org-next" appear only in: registry env values, example docs, org-next's own code, and tests that explicitly exercise the org-next entry. Tests for the generic mode itself use a synthetic `test-app` registry entry.
- Adding a second consumer in the future is purely a registry addition — no changes to auth route or server-function code.

## Key Changes

### Auth app — generic integration layer

- New module `apps/auth/src/lib/app-integration.ts`:
  - `type AppConfig = { slug, allowedOrigins, returnToPolicy: "relative-only" | { allowedOrigins }, cookieNames: { auth, refresh, id }, cookieDomain, sessionSecret, cognitoClientId? }`.
  - `resolveAppConfig(slug): AppConfig` — throws/redirects to `/error?reason=unknown_app` if missing.
  - `isAllowedReturnTo(app, value)` — enforces the app's return_to policy (default: relative paths only, no `//`, no `\`, must start with `/`).
  - `signAuthState(app, payload)` / `verifyAuthState(app, token)` — HMAC over `{ slug, returnTo, nonce, iat }` using the app's session secret. Used for the round-trip CSRF token.
- New module `apps/auth/src/lib/app-token-cookies.ts`:
  - `writeAppTokenCookies(app, tokens)` — writes the three cookies using `useSession` with names/domain/secret from `AppConfig`. Pure mapping from `AuthenticationResultType` → cookie payloads.
  - `clearAppTokenCookies(app)` — clears the three cookies for that app.
  - Both functions are the only place `authToken`/`refreshToken`/`idToken` cookie shape is defined. Org-next's existing `useAuthTokenSession`/`useRefreshTokenSession` shape is the reference; document the contract in `apps/auth/docs/app-integration.md` so any consuming app uses the same envelope.
- Registry env: introduce `AUTH_APPS` (JSON map keyed by slug) following the pattern of `AUTH_ALLOWED_URIS_BY_CLIENT_ID` in [apps/auth/src/lib/env.ts](apps/auth/src/lib/env.ts). Per-app `sessionSecret` is referenced by name (e.g. `AUTH_APPS={"org-next":{"sessionSecretEnv":"ORG_NEXT_SESSION_SECRET", ...}}`) so secrets stay in their own env vars but the registry stays one place.
- `apps/auth/src/features/auth/contracts.ts`: extend `authorizeSearchSchema` so when `app` is present, `client_id`/`redirect_uri`/`session_url` are not required and `return_to` + `auth_state` are accepted; when `app` is absent, the existing schema applies unchanged. This keeps the two modes mutually exclusive at the contract layer.
- `apps/auth/src/features/auth/server-functions.ts`:
  - `beginAuthorizeFn`: branch on `data.app`. If present, call `resolveAppConfig`, validate `return_to` via the app's policy, store `appRequest` in the transaction session (slug + returnTo + state). Otherwise keep current `oauthRequest` flow exactly as is.
  - Replace the org-next-specific cookie helper with `writeAppTokenCookies(app, authResult)` everywhere a Cognito success would have called `setAuthCookie`. The classic OAuth flow keeps using `setAuthCookie` (writes the existing `anedot-auth` SSO cookie) — no behavior change for external clients.
  - On password / MFA / new-password / sign-up confirmation success in app mode: call `writeAppTokenCookies`, then redirect to `${origin}${returnTo}` (origin chosen from the app's `allowedOrigins`, validated).
  - Do not store password in the transaction session past the confirmation auto-login step (matches the existing plan; not app-specific).
- New endpoint `POST /apps/refresh` (server function): takes `{ app: slug }`, reads that app's `refreshToken` cookie, calls Cognito refresh, rewrites the three app cookies. On failure, clears the app cookies and 401s; the consuming app then redirects to its login route. Keep the endpoint generic; no app-specific logic.
- `beginLogoutFn`: when `app` is present, resolve config, clear app token cookies via `clearAppTokenCookies`, best-effort revoke Cognito (must succeed even if revoke fails), then redirect to a validated `return_to` on that app's origin. When absent, current logout behavior is unchanged.
- Leave `session_url`, `/auth-status`, `anedot-auth`, Google/federated, and `AUTH_ALLOWED_URIS_BY_CLIENT_ID` alone for external clients.

### Org-next — first consumer of generic mode

Same behavior as the original plan, but framed around the generic contract:

- Remove `MOCK_ACCESS_TOKEN`, `VITE_TEMP_BYPASS_AUTH`, and unused `VITE_AUTH_CLIENT_ID` from env validation, templates, docs, tests, and runtime.
- Keep [src/server/session.server.ts](apps/org-next/src/server/session.server.ts) as the canonical reader for the three cookie names; add `useIdTokenSession`. Cookie names + secret must match the org-next entry in `AUTH_APPS`.
- Org-next does not call refresh directly; if `authToken` is missing/expired, server functions throw 401 and the existing middleware redirects to `/login`, which kicks the auth app's authorize-app flow.
- Update [src/routes/-auth.ts](apps/org-next/src/routes/-auth.ts):
  - `initiateLogin`: build `${VITE_AUTH_APP_URL}/authorize?app=org-next&return_to=<relative>&auth_state=<signed>` (signed locally with `SESSION_SECRET` so org-next can verify on return).
  - `performLogout`: browser-redirect to `${VITE_AUTH_APP_URL}/logout?app=org-next&return_to=/login?logged_out=1`.
- Org API auth uses only `authToken`; missing → 401 / login.

### Backend `anedot_next`

Unchanged from the original plan: validate Cognito JWT, drop `User.last` stub. Backend has no awareness of the auth app's app registry — it only validates Cognito access tokens.

## Manual Local Tasks

- Auth `.env.local`:
  - `VITE_AUTH_MOCK_MODE=false`
  - Cognito vars (`COGNITO_CLIENT_ID`, `COGNITO_CLIENT_SECRET` if needed, `COGNITO_USER_POOL_ID`, `COGNITO_REGION`)
  - `AUTH_APPS={"org-next":{"sessionSecretEnv":"ORG_NEXT_SESSION_SECRET","allowedOrigins":["http://localhost:3210"],"cookieNames":{"auth":"authToken","refresh":"refreshToken","id":"idToken"},"cookieDomain":""}}`
  - `ORG_NEXT_SESSION_SECRET=<same value as org-next SESSION_SECRET>`
  - Keep `AUTH_ALLOWED_URIS_BY_CLIENT_ID` for existing external clients.
- Org-next `.env.local`:
  - `SESSION_SECRET=<same as ORG_NEXT_SESSION_SECRET>`
  - `VITE_AUTH_APP_URL=http://localhost:3208`
  - Remove `MOCK_ACCESS_TOKEN`, `VITE_TEMP_BYPASS_AUTH`, `VITE_AUTH_CLIENT_ID`.
- Cognito: existing app client; access token must include `email`.

## Test Plan

- **Auth — generic registry & app mode** (use a synthetic `test-app` entry in tests; do not mention `org-next`):
  - Registry parsing, missing/malformed `AUTH_APPS`, unknown app → `/error?reason=unknown_app`.
  - `isAllowedReturnTo`: relative-only policy, rejects `//evil.com`, `\evil`, absolute URLs unless allowed.
  - `signAuthState`/`verifyAuthState`: tamper, slug mismatch, expiry.
  - `writeAppTokenCookies`/`clearAppTokenCookies`: writes the configured names with the configured domain/secret; round-trips via `useSession`.
  - `beginAuthorizeFn` in app mode: stores `appRequest`, redirects to `/sign-in`.
  - Password / MFA / new-password / confirm-sign-up success in app mode: cookies written, return redirect to validated origin + relative `return_to`.
  - Refresh endpoint: success rewrites cookies; failure clears them and returns 401.
  - Logout in app mode clears app cookies even when Cognito revoke throws.
- **Auth — existing classic mode**: keep current `session_url`, bootstrap JWT, Google/federated, and allowlist tests intact and passing.
- **Auth — org-next-specific test**: one focused integration test asserting the `org-next` registry entry resolves and produces the expected cookie names/origins (smoke test for the env wiring only).
- **Org-next**:
  - Login URL construction includes `app=org-next`, signed `auth_state`, and the original relative route as `return_to`.
  - State verification on return; mismatched/missing state → re-initiate login.
  - Original-route restoration after auth.
  - `useIdTokenSession` reader.
  - Missing `authToken` cookie → 401 → `/login` (no mock fallback).
  - Playwright fixtures create explicit signed `authToken`/`idToken` cookies; refresh cookie only when a test exercises auth refresh/logout.
- **Backend**: missing token, invalid JWT, wrong token type, missing email claim, existing user lookup, new user creation.

## Docs

- New `apps/auth/docs/app-integration.md` (generic): describes the same-domain token cookie integration mode, the `app` registry shape, the three cookie envelope, return_to/auth_state contract, refresh endpoint, and logout. Written for "any future Anedot app", not for org-next.
- Update `apps/auth/docs/spec.md` to point at the new mode as a peer of the existing OAuth flow.
- Update [apps/org-next/docs/README.md](apps/org-next/docs/README.md) "Auth flow" section to describe org-next as a consumer of the generic mode and link to `apps/auth/docs/app-integration.md`.
- Leave `apps/auth/docs/client-integration.md` and `apps/auth/docs/session-bootstrap.md` unchanged for external clients.

## Assumptions

- Same parent domain in production (e.g. `.anedot.com`) so cookies set with `cookieDomain` from the app config are readable by the consuming app. Localhost dev relies on cookies-per-host scoping.
- Cookie envelope (TanStack `useSession` shape with the three names) is the contract any consuming app must adopt.
- Refresh remains auth-owned; consuming apps never see the refresh token.
- Existing OAuth/`session_url` clients keep working unchanged.
- Org-next continues to own `userSession` and its own `SESSION_SECRET`, which equals the auth-side `ORG_NEXT_SESSION_SECRET`.
