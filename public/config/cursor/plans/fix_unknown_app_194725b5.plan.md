---
name: Fix Unknown App
overview: Fix the local org-next to auth app-mode sign-in failure by adding the missing auth app registry configuration and a small guardrail so the error is easier to diagnose next time.
todos:
  - id: update-auth-env-template
    content: Add org-next AUTH_APPS and ORG_NEXT_SESSION_SECRET examples to apps/auth/.env.template.
    status: completed
  - id: update-auth-env-local
    content: Create or update apps/auth/.env.local with the local org-next AUTH_APPS entry and matching ORG_NEXT_SESSION_SECRET.
    status: completed
  - id: update-org-next-env-local
    content: Create or update apps/org-next/.env.local with the required local dev env vars.
    status: completed
  - id: fix-org-next-env-template
    content: Replace stale API_HOSTNAME with ANEDOT_API_URL_BASE in apps/org-next/.env.template.
    status: completed
  - id: align-shared-secret
    content: Ensure AUTH_APPS["org-next"].sessionSecretEnv points at ORG_NEXT_SESSION_SECRET and matches org-next SESSION_SECRET.
    status: completed
  - id: document-unknown-app
    content: Document local org-next app-mode env setup and unknown_app diagnosis.
    status: completed
  - id: validate-auth
    content: Run focused auth validation after the env/docs changes.
    status: completed
isProject: false
---

# Fix Unknown App

## Diagnosis

Org-next builds login URLs with `app=org-next` in [`apps/org-next/src/server/auth-state.ts`](apps/org-next/src/server/auth-state.ts):

```33:53:apps/org-next/src/server/auth-state.ts
export function buildLoginUrl(
  authAppOrigin: string,
  sessionSecret: string,
  returnTo: string,
): string {
  // ...
  url.searchParams.set("app", APP_SLUG);
  url.searchParams.set("return_to", safeReturnTo);
  url.searchParams.set("auth_state", authState);
  return url.toString();
}
```

Auth then resolves that slug only from `AUTH_APPS` in [`apps/auth/src/lib/app-integration.ts`](apps/auth/src/lib/app-integration.ts). If the running auth process has no `AUTH_APPS.org-next` entry, it redirects to `/error?reason=unknown_app` in [`apps/auth/src/features/auth/server-functions.ts`](apps/auth/src/features/auth/server-functions.ts).

The local repo has no [`apps/auth/.env.local`](apps/auth/.env.local) or [`apps/auth/.env`](apps/auth/.env), and [`apps/auth/.env.template`](apps/auth/.env.template) currently lacks both `AUTH_APPS` and `ORG_NEXT_SESSION_SECRET`, so a local auth app booted from the template cannot recognize `org-next`.

## Plan

1. Update [`apps/auth/.env.template`](apps/auth/.env.template) with a local `AUTH_APPS` entry for `org-next`:
   - Key: `org-next`
   - `sessionSecretEnv`: `ORG_NEXT_SESSION_SECRET`
   - `allowedOrigins`: `http://localhost:3210`
   - cookie names: `authToken`, `refreshToken`, `idToken`
   - `cookieDomain`: empty string for localhost host-scoped cookies

2. Add `ORG_NEXT_SESSION_SECRET` to [`apps/auth/.env.template`](apps/auth/.env.template), matching the example `SESSION_SECRET` in [`apps/org-next/.env.template`](apps/org-next/.env.template), with comments explaining the two values must match byte-for-byte.

3. Create or update [`apps/auth/.env.local`](apps/auth/.env.local) with the same local `org-next` app registry entry and matching `ORG_NEXT_SESSION_SECRET`, so `pnpm --filter auth dev` works immediately on this machine. Keep secrets local-only; do not add production values.

4. Create or update [`apps/org-next/.env.local`](apps/org-next/.env.local) with the required local dev vars:
   - `ANEDOT_API_URL_BASE=http://localhost:3000`
   - `SESSION_SECRET=<same value used by auth ORG_NEXT_SESSION_SECRET>`
   - `VITE_ENABLE_RMP=false`
   - `VITE_ROLLBAR_ACCESS_TOKEN=<local placeholder>`
   - `VITE_AUTH_APP_URL=http://localhost:3208`

5. Fix [`apps/org-next/.env.template`](apps/org-next/.env.template) to use `ANEDOT_API_URL_BASE` instead of stale `API_HOSTNAME`, matching [`apps/org-next/src/env.ts`](apps/org-next/src/env.ts).

6. Explicitly align the shared-secret contract:
   - auth `AUTH_APPS["org-next"].sessionSecretEnv` points at `ORG_NEXT_SESSION_SECRET`
   - auth `ORG_NEXT_SESSION_SECRET` equals org-next `SESSION_SECRET`

7. Update docs in [`apps/auth/docs/app-integration.md`](apps/auth/docs/app-integration.md) or [`apps/auth/README.md`](apps/auth/README.md) with the local dev env snippet and the symptom mapping:
   - `/error?reason=unknown_app` means the auth app's running `AUTH_APPS` does not include the `app` query slug.
   - For org-next local sign-in, the auth app must be restarted after changing env.

8. Add or adjust a small test around the template/config expectation if there is an existing env-template test pattern. If not, keep validation to existing unit and e2e coverage.

9. Validate with:
   - `mise exec -- pnpm --filter auth test`
   - `mise exec -- pnpm --filter auth typecheck`
   - `mise exec -- pnpm --filter auth e2e`

## Immediate Local Workaround

Before code changes, you can unblock manually by creating [`apps/auth/.env.local`](apps/auth/.env.local) and adding:

```bash
ORG_NEXT_SESSION_SECRET=3a76a3c0-5cc3-41a9-9258-5c9a82b94159
AUTH_APPS={"org-next":{"sessionSecretEnv":"ORG_NEXT_SESSION_SECRET","allowedOrigins":["http://localhost:3210"],"cookieNames":{"auth":"authToken","refresh":"refreshToken","id":"idToken"},"cookieDomain":""}}
```

Then restart the auth dev server.