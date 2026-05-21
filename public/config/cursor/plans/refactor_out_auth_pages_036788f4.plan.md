---
name: Refactor out auth pages
overview: Remove the `/signup` and `/logout` routes from org-next, strip signup references from `/login` and auth helpers, and add a server function that hits the auth app's `/logout` endpoint and verifies our session cookies were cleared.
todos:
  - id: delete_signup
    content: Delete src/routes/_login/signup.tsx
    status: completed
  - id: delete_logout
    content: Delete src/routes/_login/logout.tsx
    status: completed
  - id: strip_signup_login_page
    content: Remove 'Don’t have an account? Sign up' link + unused Link import from src/routes/_login/login.tsx
    status: completed
  - id: simplify_auth_helpers
    content: Drop initiateSignup / redirectToLogin / screenHint from src/routes/_login/-auth.ts
    status: completed
  - id: simplify_lib_auth
    content: Drop screenHint from LoginStartOptions/LoginOptions and screen_hint branch from buildLoginStartPath in src/lib/auth.ts
    status: completed
  - id: add_perform_logout
    content: Add performLogout server function in src/routes/_login/-auth.ts that hits AUTH_APP_URL/logout, verifies session cookies cleared, and reports to Rollbar otherwise
    status: completed
  - id: regen_route_tree
    content: Regenerate src/routeTree.gen.ts via dev/build so /signup and /logout entries are removed
    status: completed
  - id: update_docs
    content: Rewrite apps/org-next/docs/README.md auth section to match what's actually implemented — remove all references to oauth/start, oauth/callback, signup, and logout flows; describe only the /login entry, session cookies, and 401 redirect
    status: completed
isProject: false
---

## Background

Currently org-next ships three auth pages:

- `/login` — a "Continue to Sign In" button that kicks off the OAuth flow to the auth app.
- `/signup` — a near-duplicate of login with a "Google / email sign up" UI.
- `/logout` — an empty spinner page.

Per `apps/auth/docs/client-integration.md`, the auth app owns sign-in, sign-up, logout, and session cookies. Org-next should delegate all three, leaving only a thin `/login` entry page (kept because `_authed`, the app-bootstrap loader, and the global 401 middleware all `redirect({ to: "/login" })`).

## Scope

Keep `/login`. Remove `/signup`. Remove `/logout`. Never mention sign-up. Add a logout server function that calls the auth app's forthcoming `/logout` endpoint, then verifies our session cookies are cleared and reports to Rollbar if they aren't.

Existing redirect targets in [src/server/middleware.ts](apps/org-next/src/server/middleware.ts) and [src/server/app-bootstrap.ts](apps/org-next/src/server/app-bootstrap.ts) remain pointed at `/login`. No UI wiring for the new logout helper as part of this change.

## Changes

### 1. Delete signup route

Remove [src/routes/_login/signup.tsx](apps/org-next/src/routes/_login/signup.tsx) entirely.

### 2. Delete logout page route

Remove [src/routes/_login/logout.tsx](apps/org-next/src/routes/_login/logout.tsx) entirely. It will be replaced by a server function (see 4).

### 3. Strip signup from the login page and shared helpers

In [src/routes/_login/login.tsx](apps/org-next/src/routes/_login/login.tsx):

- Remove the `Link` import and the entire "Don't have an account? Sign up" paragraph at the bottom (lines ~68–76).
- Keep `redirectIfAuthenticated`, keep the "Continue to Sign In" button and its `initiateLogin()` call.

In [src/routes/_login/-auth.ts](apps/org-next/src/routes/_login/-auth.ts):

- Remove `initiateSignup` and the unused `redirectToLogin`.
- Remove the `screenHint` option from the remaining `initiateLogin` call site.

In [src/lib/auth.ts](apps/org-next/src/lib/auth.ts):

- Remove `screenHint?: "sign_up"` from `LoginStartOptions` and `LoginOptions`.
- Remove the `screen_hint` branch in `buildLoginStartPath`.

### 4. Add a logout server function

Add a new `performLogout` to [src/routes/_login/-auth.ts](apps/org-next/src/routes/_login/-auth.ts) using `createServerFn`:

```ts
export const performLogout = createServerFn({ method: "POST" }).handler(async () => {
  await fetch(`${env.AUTH_APP_URL}/logout`, { method: "POST" });

  const [authToken, refreshToken, account] = await Promise.all([
    useAuthTokenSession(),
    useRefreshTokenSession(),
    useAccountSession(),
  ]);

  const leftovers = [
    authToken.data.authToken && "authToken",
    refreshToken.data.refreshToken && "refreshToken",
    account.data.accountId && "__session",
  ].filter(Boolean);

  if (leftovers.length) {
    reportServerError(new Error(`auth cookies not cleared after /logout: ${leftovers.join(", ")}`));
  }
});
```

Notes:

- Uses existing cookie readers in [src/server/session.server.ts](apps/org-next/src/server/session.server.ts) (`useAuthTokenSession`, `useRefreshTokenSession`, `useAccountSession`).
- Reports via the existing server Rollbar helper in [src/server/rollbar-server.server.ts](apps/org-next/src/server/rollbar-server.server.ts) (use whatever `report*` export it provides; adjust import name if needed).
- Uses `env.AUTH_APP_URL` from [src/env.ts](apps/org-next/src/env.ts).
- No UI call site added in this change. The helper is exported for future use.

### 5. Regenerate the route tree

[src/routeTree.gen.ts](apps/org-next/src/routeTree.gen.ts) is auto-generated by the TanStack Router dev/build tooling. After deleting `signup.tsx` and `logout.tsx`, running the dev server (or `pnpm build`) will rewrite this file to drop the `/signup` and `/logout` routes.

### 6. Docs update — make it match reality

The current [apps/org-next/docs/README.md](apps/org-next/docs/README.md) "Auth Flow (cross-app)" section describes an `/oauth/start` + `/oauth/callback` flow that does not exist anywhere in the codebase (there are no such routes in org-next or in `apps/auth`; the only reference is a dead URL literal in [src/lib/auth.ts](apps/org-next/src/lib/auth.ts)). It also mentions signup, which we're removing. Replace the section with a description of what's actually implemented:

- Remove all references to `/oauth/start`, `/oauth/callback`, signup flows, and logout flows.
- Document only what exists after this refactor:
  - `/login` is the single local auth route and is the redirect target for `_authed` (see [src/routes/_authed.tsx](apps/org-next/src/routes/_authed.tsx)), the app-bootstrap loader ([src/server/app-bootstrap.ts](apps/org-next/src/server/app-bootstrap.ts)), and the global 401 middleware ([src/server/middleware.ts](apps/org-next/src/server/middleware.ts)).
  - Session cookies (`authToken`, `refreshToken`, `__session`) are defined in [src/server/session.server.ts](apps/org-next/src/server/session.server.ts). Org-next reads them to resolve access tokens for Org API calls; it does not write them from its own routes.
  - The actual cross-app auth handshake is owned by `apps/auth` (see `apps/auth/docs/client-integration.md`) and is not yet wired up in org-next — explicitly call this out so future agents don't take the old docs as gospel.

Rewritten section (proposed content for `docs/README.md` "Auth Flow (cross-app)"):

```md
## Auth Flow (cross-app)

Org-next has a single auth-related route: `/login`
(`src/routes/_login/login.tsx`). It's a static page with a "Continue to
Sign In" button. `_authed`, the app-bootstrap loader, and the global
401 middleware in `src/start.ts` all redirect here on unauthenticated
access.

Org-next never touches Cognito directly. It only reads the httpOnly
session cookies defined in `src/server/session.server.ts` to resolve the
access token for Org API calls. Those cookies are set by the separate
auth app (`AUTH_APP_URL`), which also owns sign-in, sign-up, MFA, and
logout — see `apps/auth/docs/client-integration.md` for that contract.

The wiring from `/login` into the auth app's `/authorize` entry point is
not yet implemented in this codebase; the existing `buildLoginStartPath`
helper points to a placeholder path. Dev environments bypass the flow
via `VITE_TEMP_BYPASS_AUTH`.

Logout is a server function, `performLogout` in
`src/routes/_login/-auth.ts`. It calls the auth app's `/logout`
endpoint, then re-reads the session cookies and reports to Rollbar if
any are still present.
```

## Non-goals / explicitly left alone

- No new implementation of the `/authorize` handshake or a code-exchange callback route — docs call this out as a known gap.
- No change to session cookie layout in [src/server/session.server.ts](apps/org-next/src/server/session.server.ts).
- No change to redirect targets in [src/server/middleware.ts](apps/org-next/src/server/middleware.ts) or [src/server/app-bootstrap.ts](apps/org-next/src/server/app-bootstrap.ts) — both continue to redirect to `/login`.
- No UI wiring of `performLogout` (e.g. into `app-header.tsx`) — out of scope.
- No test changes expected; `tests/` does not reference `/signup`, `/logout`, or signup helpers.

