---
name: fix server import protection
overview: Resolve the TanStack Start import-protection build error by moving `resolveSelectedTenantId` (the only unstripped caller of `.server` code) into the `.server.ts` file so `user-session.ts` no longer pulls server-only values into the client graph.
todos:
  - id: add_utils
    content: Create apps/org-next/src/server/user-session-utils.ts containing pickSelectedTenantId
    status: pending
  - id: move_resolve
    content: Move resolveSelectedTenantId into user-session.server.ts wrapped in createServerOnlyFn, importing pickSelectedTenantId from user-session-utils
    status: pending
  - id: slim_user_session
    content: Slim user-session.ts to only the createServerFn wrappers and type re-exports
    status: pending
  - id: update_app_bootstrap
    content: Update app-bootstrap.ts to import resolveSelectedTenantId from ./user-session.server
    status: pending
  - id: update_test
    content: Update user-session.test.ts to import pickSelectedTenantId from ./user-session-utils
    status: pending
  - id: verify_build
    content: Run pnpm --filter org-next build and test to confirm the fix
    status: pending
isProject: false
---

## Root cause recap

`src/routes/__root.tsx` imports from [`src/server/user-session.ts`](apps/org-next/src/server/user-session.ts), putting that module in the client graph. `user-session.ts` contains `resolveSelectedTenantId`, a plain async function (not wrapped in `createServerFn`/`createServerOnlyFn`) that calls `readUserSession()` from [`src/server/user-session.server.ts`](apps/org-next/src/server/user-session.server.ts). Because the body isn't stripped, the `.server.*` import survives into the client env and the `tanstack-start-core:import-protection` plugin denies it.

## Changes

### 1. Move `resolveSelectedTenantId` into `user-session.server.ts`

Add to [`apps/org-next/src/server/user-session.server.ts`](apps/org-next/src/server/user-session.server.ts):

```ts
import type { Tenant } from "@/types/bootstrap";
import { pickSelectedTenantId } from "./user-session-utils";

export const resolveSelectedTenantId = createServerOnlyFn(
  async (tenants: Tenant[]): Promise<number | null> => {
    const session = await readUserSession();
    const picked = pickSelectedTenantId(tenants, session.selectedTenantId);
    if (picked !== null && picked !== session.selectedTenantId) {
      await writeUserSession({ selectedTenantId: picked });
    }
    return picked;
  },
);
```

Wrapping with `createServerOnlyFn` gives a clear runtime error if it is ever accidentally called from the client, matching the pattern already used for `readUserSession`/`writeUserSession`.

### 2. Extract the pure helper `pickSelectedTenantId`

`pickSelectedTenantId` is pure and is imported by the test file. To avoid a new server→client cycle (`user-session.server.ts` importing `user-session.ts`), move it to a new client-safe module:

- New file: `apps/org-next/src/server/user-session-utils.ts` containing just `pickSelectedTenantId` (copied verbatim from lines 27–44 of the current `user-session.ts`).

### 3. Slim down `user-session.ts`

[`apps/org-next/src/server/user-session.ts`](apps/org-next/src/server/user-session.ts) becomes only `createServerFn` wrappers plus type re-exports:

```ts
import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import {
  readUserSession,
  writeUserSession,
  type UserSession,
} from "./user-session.server";

const userSessionUpdateSchema = z.object({
  selectedTenantId: z.number().int().nullable().optional(),
  theme: z.enum(["light", "dark", "system"]).optional(),
});

export const getUserSession = createServerFn({ method: "GET" }).handler(
  async (): Promise<UserSession> => readUserSession(),
);

export const updateUserSession = createServerFn({ method: "POST" })
  .inputValidator(userSessionUpdateSchema)
  .handler(async ({ data }): Promise<UserSession> => writeUserSession(data));

export type { Theme, UserSession } from "./user-session.server";
```

The value imports (`readUserSession`, `writeUserSession`) are now only referenced inside `createServerFn(...).handler(...)`, whose bodies TanStack Start strips from the client bundle, so the `.server.*` import is no longer reachable in the client env.

### 4. Update callers

- [`apps/org-next/src/server/app-bootstrap.ts`](apps/org-next/src/server/app-bootstrap.ts) line 5: change import to `./user-session.server`:
  ```ts
  import { resolveSelectedTenantId } from "./user-session.server";
  ```
  This is fine because `app-bootstrap.ts` only exposes `getAppBootstrapData` via `createServerFn`, so the `.server` import is inside a stripped boundary.

- [`apps/org-next/src/server/user-session.test.ts`](apps/org-next/src/server/user-session.test.ts) line 3: change to `./user-session-utils`.

## Verification

- `pnpm --filter org-next build` should now succeed (no import-protection denial).
- `pnpm --filter org-next test` should still pass (the test only uses the pure `pickSelectedTenantId`).
- Client bundle should contain neither `readUserSession` nor `writeUserSession` source.