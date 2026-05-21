---
name: Fix auth_state secret
overview: Fix the local env wiring that causes `invalid_auth_state` when org-next redirects to the auth app.
todos: []
isProject: false
---

# Fix `invalid_auth_state` for org-next local sign-in

## Diagnosis

`invalid_auth_state` happens before sign-in. It is raised by the auth app when this check fails in [`apps/auth/src/features/auth/server-functions.ts`](apps/auth/src/features/auth/server-functions.ts):

```ts
const verified = verifyAuthState(app, data.auth_state);
if (!verified.ok) {
  throw redirect({ to: "/error", search: { reason: "invalid_auth_state" } });
}
```

The signature is created by org-next with [`apps/org-next/src/server/auth-app-url.server.ts`](apps/org-next/src/server/auth-app-url.server.ts), which passes `env.SESSION_SECRET` into `buildLoginUrl`:

```ts
return buildLoginUrl(env.VITE_AUTH_APP_URL, env.SESSION_SECRET, returnTo);
```

The auth app verifies the same token using the `sessionSecretEnv` value from `AUTH_APPS`, resolved in [`apps/auth/src/lib/app-integration.ts`](apps/auth/src/lib/app-integration.ts). Your current local envs have `apps/org-next/.env.local` `SESSION_SECRET` and `apps/auth/.env.local` `ORG_NEXT_SESSION_SECRET` set to different values, so HMAC verification fails and auth redirects to `/error?reason=invalid_auth_state`.

## Plan

1. In [`apps/auth/.env.local`](apps/auth/.env.local), set `ORG_NEXT_SESSION_SECRET` to exactly the same value as [`apps/org-next/.env.local`](apps/org-next/.env.local) `SESSION_SECRET`.

2. In [`apps/org-next/.env.local`](apps/org-next/.env.local), remove `AUTH_SESSION_SECRET`; org-next does not read it and it can be confused with `SESSION_SECRET`.

3. Keep `AUTH_SESSION_SECRET` only in [`apps/auth/.env.local`](apps/auth/.env.local). It is auth-app-private and should not match org-next's `SESSION_SECRET` unless by accident.

4. Fix the next local-dev auth concern while we are there: in [`../anedot_next/.env`](../anedot_next/.env), replace the placeholder `LOCAL_DEV_JWT_SECRET` with the same value used by [`apps/auth/.env.local`](apps/auth/.env.local) `LOCAL_DEV_JWT_SECRET`. This does not cause `invalid_auth_state`, but it will cause Rails 401s after sign-in if left mismatched.

5. Optionally remove the legacy `VITE_AUTH_MOCK_MODE=true` from [`apps/auth/.env.local`](apps/auth/.env.local) since `ANEDOT_LOCAL_DEV=true` is now the canonical flag.

6. Restart both dev servers after changing env files:

```bash
pnpm --filter org-next dev
pnpm --filter auth dev
```

Restart `anedot_next` too if the Rails secret is updated.

## Expected Result

After the two app secrets match, org-next will sign `auth_state` with the same secret the auth app uses to verify it. The redirect should go from org-next `/login` to auth `/sign-in` instead of `/error?reason=invalid_auth_state`.