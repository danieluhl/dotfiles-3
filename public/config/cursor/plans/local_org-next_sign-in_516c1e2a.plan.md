---
name: Local org-next sign-in
overview: Get local sign-in into org-next via the auth app working without going through Cognito email confirmation, using the auth app's already-built mock mode plus the org-next test-seed escape hatch for real-token scenarios.
todos: []
isProject: false
---

## Local sign-in into org-next via the auth app

The two apps already have everything you need; this is mostly an env-file + workflow change, not a code change. Two complementary local bypasses are already built into the apps:

### Option A — Mock mode (fastest; UI-only, no Cognito, no real backend)

The auth app supports `VITE_AUTH_MOCK_MODE=true` which makes [submitSignInFn](apps/auth/src/features/auth/server-functions.ts) accept **any email + any password**, skip Cognito, and write valid signed `authToken`/`refreshToken`/`idToken` cookies for org-next. Same for sign-up + confirm — codes are not validated. This is the “bypass the email code” path.

Caveat: the access token in those cookies is `mock-access-<uuid>`. The Rails `anedot_next` backend at `http://localhost:3000` will return 401 for that token, which org-next will turn back into `/login`. Use this option when you only need the UI flow or are mocking the backend.

Steps:

1. Create `apps/auth/.env.local` from `apps/auth/.env.template`. Keep:

   ```
   VITE_AUTH_MOCK_MODE=true
   AUTH_SESSION_SECRET=<>=32 chars, not the placeholder value>
   ORG_NEXT_SESSION_SECRET=3a76a3c0-5cc3-41a9-9258-5c9a82b94159
   AUTH_APPS={"org-next":{"sessionSecretEnv":"ORG_NEXT_SESSION_SECRET","allowedOrigins":["http://localhost:3210"],"cookieNames":{"auth":"authToken","refresh":"refreshToken","id":"idToken"},"cookieDomain":""}}
   ```

   Cognito vars can stay empty.

2. Create `apps/org-next/.env.local` from [apps/org-next/.env.template](apps/org-next/.env.template). Critical: `SESSION_SECRET` MUST equal `ORG_NEXT_SESSION_SECRET` byte-for-byte, and `VITE_AUTH_APP_URL=http://localhost:3208` must match the auth app's port.

3. Restart both dev servers (env changes do not hot-reload).

4. In the browser, hit `http://localhost:3210/login`. You'll be bounced to `http://localhost:3208/sign-in?...`. Enter any email + any password and submit. The auth app writes the three signed cookies for org-next and redirects back; you're now signed in. Special test emails: any email containing `mfa`, `newpass`, or `unconfirmed` triggers the corresponding mock challenge (see [server-functions.ts](apps/auth/src/features/auth/server-functions.ts) lines ~474–500); avoid those substrings for the simple path.

If you instead see `/error?reason=unknown_app`, the running auth process did not load `AUTH_APPS["org-next"]` — restart auth after the env edit. This is documented in [apps/auth/docs/app-integration.md](apps/auth/docs/app-integration.md).

### Option B — Test-seed cookies (real Cognito access token, real backend)

If Option A's mock token can't reach the real backend, skip the auth app entirely for sign-in and seed real cookies directly via the org-next test-only endpoint. The route is [apps/org-next/src/routes/test-seed.auth.ts](apps/org-next/src/routes/test-seed.auth.ts) and is gated by `E2E_TEST_SEED=true`.

1. Add `E2E_TEST_SEED=true` to `apps/org-next/.env.local`. (See the production warning in the [docs](apps/org-next/docs/README.md): never set this on a deployed env.)

2. Restart org-next.

3. Obtain a real Cognito access token for an admin user. Two easy ways:
   - One-off, never-expires sign-up: run a real `pnpm --filter auth dev` against the real Cognito user pool and sign up. To skip the emailed confirmation code, run AWS CLI as a pool admin:
     - `aws cognito-idp admin-confirm-sign-up --user-pool-id <pool> --username <email> --region us-west-2`
     - or pre-create a confirmed admin user with `aws cognito-idp admin-create-user … --message-action SUPPRESS` followed by `admin-set-user-password … --permanent`.
   - Or grab a still-valid `accessToken` value from any existing `authToken` cookie you already have.
4. Visit `http://localhost:3210/test-seed/auth?authToken=<paste-token>&idToken=<optional>&refreshToken=<optional>`. The route just returns nothing visible; cookies are now set. Navigate to `/` and you're signed in — server functions in [src/server/org-api.server.ts](apps/org-next/src/server/org-api.server.ts) will forward the real token to the Rails backend.

5. To clear: `http://localhost:3210/test-seed/auth?action=clear`.

### Decision guide

- Just want UI-level sign-in for org-next pages without a real backend → Option A.
- Need to actually call the Rails API at `localhost:3000` while signed in → Option B with a Cognito token from an admin-confirmed user.

### Notes / non-goals

- No code changes are required. Both bypasses already exist and are documented in [apps/auth/docs/app-integration.md](apps/auth/docs/app-integration.md) and [apps/org-next/docs/README.md](apps/org-next/docs/README.md).
- `E2E_TEST_SEED` and `VITE_AUTH_MOCK_MODE` must never be set in production.
- If you'd prefer a single "always-let-me-in as admin" button (e.g. a dev-only link on the auth sign-in screen that mints a real Cognito token via the Admin API), that is a small additional code change and we should treat it as a follow-up — happy to write that plan if you want it.