---
name: fix-e2e-api-hostname-mocks
overview: Make Playwright mock URL patterns derive from `API_HOSTNAME` so they stop going stale, and fix the currently-failing `homepage.spec.ts` (and the sibling specs broken for the same reason) caused by the `.env.e2e` change from `:3210` to `:3000`.
todos:
  - id: create_helper
    content: Add apps/org-next/tests/get-mock-api-urls.ts that reuses the app's @t3-oss/env-core `env` from ../src/env and exports regex builders for every mocked endpoint.
    status: completed
  - id: update_homepage_spec
    content: Update tests/homepage.spec.ts to use getMockApiUrls() instead of hardcoded :3210 patterns.
    status: completed
  - id: update_campaigns_spec
    content: Update tests/campaigns.spec.ts (five named patterns plus the inline vendor pattern) to use getMockApiUrls().
    status: completed
  - id: update_root_error_spec
    content: Update tests/root-error.spec.ts to use getMockApiUrls().usersMe.
    status: completed
  - id: update_organizations_new_spec
    content: Update tests/organizations-new.spec.ts to use getMockApiUrls() and decouple the final toHaveURL assertions from the :3210 port.
    status: completed
  - id: update_smoke_spec
    content: Update tests/smoke.spec.ts to use getMockApiUrls().
    status: completed
  - id: run_playwright
    content: Run `pnpm exec playwright test` from apps/org-next and confirm all specs pass.
    status: completed
isProject: false
---

## Root cause (recap)

`.env.e2e` was refactored from `VITE_API_HOSTNAME=http://localhost:3210` to server-only `API_HOSTNAME=http://localhost:3000`, but every test file still hardcodes `http://localhost:3210/...` in its regex patterns (see [tests/homepage.spec.ts](apps/org-next/tests/homepage.spec.ts), [tests/campaigns.spec.ts](apps/org-next/tests/campaigns.spec.ts), [tests/root-error.spec.ts](apps/org-next/tests/root-error.spec.ts), [tests/organizations-new.spec.ts](apps/org-next/tests/organizations-new.spec.ts), [tests/smoke.spec.ts](apps/org-next/tests/smoke.spec.ts)).

Because the outbound URL from [src/server/org-api.server.ts](apps/org-next/src/server/org-api.server.ts) is now `http://localhost:3000/...`, the regexes never match. RMP falls through to the real backend, the test snapshot shows actual seed data (`person@example.com`, "my test campaign"), and `toHaveURL(/\/organizations\/new/)` fails because the real user actually has a tenant and stays on `/`.

## Fix

### 1. New helper: `apps/org-next/tests/get-mock-api-urls.ts`

Reuses the app's existing `@t3-oss/env-core` instance from [src/env.ts](apps/org-next/src/env.ts), so `API_HOSTNAME` is validated by the same Zod schema (`z.url()`) the server uses. Playwright's test runner does not resolve the `@/*` tsconfig path mapping by default, so import with a relative path.

```ts
import { env } from "../src/env";

const origin = new URL(env.API_HOSTNAME).origin;
const escaped = origin.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

export function getMockApiUrls() {
  return {
    origin,
    usersMe: new RegExp(`^${escaped}/users/me(?:\\?|$)`),
    tenants: new RegExp(`^${escaped}/tenants(?:\\?|$)`),
    campaignsIndex: (tenantId: number) =>
      new RegExp(`^${escaped}/campaigns\\?[^#]*tenant_id=${tenantId}`),
    campaignsIndexExact: (tenantId: number) =>
      new RegExp(`^${escaped}/campaigns\\?[^#]*tenant_id=${tenantId}$`),
    campaignsIndexVendor: (tenantId: number, vendorId: number) =>
      new RegExp(
        `^${escaped}/campaigns\\?[^#]*tenant_id=${tenantId}[^#]*vendor_id=${vendorId}`,
      ),
    campaignShow: (campaignId: number, tenantId: number) =>
      new RegExp(
        `^${escaped}/campaigns/${campaignId}\\?[^#]*tenant_id=${tenantId}`,
      ),
  };
}
```

Error behavior comes for free: if `API_HOSTNAME` is missing or not a URL, `createEnv` runs its `onValidationError` handler at module import time:

```20:31:apps/org-next/src/env.ts
  onValidationError: (issues) => {
    const formatted = issues
      .map((issue) => {
        const path = issue.path
          ?.map((p) => (typeof p === "object" ? p.key : p))
          .join(".");
        return path ? `  - ${path}: ${issue.message}` : `  - ${issue.message}`;
      })
      .join("\n");
    console.error(`\nInvalid environment variables:\n${formatted}\n`);
    throw new Error(`Invalid environment variables:\n${formatted}`);
  },
```

That gives us the descriptive failure the user asked for, with no duplicated env-parsing logic in the test helper.

Note: importing `../src/env` in tests will trigger validation of every var in [src/env.ts](apps/org-next/src/env.ts) (server + VITE_*), not just `API_HOSTNAME`, because `skipValidation: typeof window !== "undefined"` evaluates to `false` in the Node test process. All of those vars are already present in `.env.e2e` (`API_HOSTNAME`, `SESSION_SECRET`, `MOCK_ACCESS_TOKEN`, `VITE_TEMP_BYPASS_AUTH`, `VITE_ENABLE_RMP`, `VITE_ROLLBAR_ACCESS_TOKEN`, `VITE_AUTH_APP_URL`), so this is fine — and it's arguably a feature: any future missing e2e env var will fail loudly at test startup instead of mysteriously later.

### 2. Update every spec to use the helper

Replace the hand-written `/http:\/\/localhost:3210\/.../` patterns with calls to `getMockApiUrls()`. Files to update:

- [tests/homepage.spec.ts](apps/org-next/tests/homepage.spec.ts) — the failing test. Replace `usersApiPattern` / `tenantsApiPattern` with `urls.usersMe` / `urls.tenants`.
- [tests/campaigns.spec.ts](apps/org-next/tests/campaigns.spec.ts) — replace all five patterns (`usersApiPattern`, `tenantsApiPattern`, `campaignsIndexPattern`, `createCampaignPattern`, `campaignShowPattern`) and the inline vendor pattern on line 133.
- [tests/root-error.spec.ts](apps/org-next/tests/root-error.spec.ts) — replace `usersApiPattern`.
- [tests/organizations-new.spec.ts](apps/org-next/tests/organizations-new.spec.ts) — replace `usersApiPattern`, `tenantsApiPattern`, and the two inline campaigns patterns; also change the `toHaveURL(/^http:\/\/localhost:3210\/?$/)` assertions to use the Playwright `baseURL` (e.g. `await expect(page).toHaveURL(/\/$/)`) so they stop coupling to the API port.
- [tests/smoke.spec.ts](apps/org-next/tests/smoke.spec.ts) — replace `usersApiPattern` / `tenantsApiPattern`.

### 3. Ensure env vars are available in the Playwright process

[playwright.config.ts](apps/org-next/playwright.config.ts) already calls `dotenv.config({ path: testEnvPath, override: true })` at the top of the file (line 10), which loads `apps/org-next/.env.e2e` into `process.env` before tests import anything. That means `tests/get-mock-api-urls.ts` (and the `env` it imports from `../src/env`) see all the required vars at module load. No changes needed here.

## Verification

```bash
cd apps/org-next
pnpm exec playwright test
```

All five test files should pass. To confirm the guard works, temporarily unset `API_HOSTNAME` in `.env.e2e` — the suite should fail on the first spec import with t3-env's formatted `Invalid environment variables:` error listing `API_HOSTNAME`.

## Out of scope (flagged for follow-up, not in this plan)

The RMP guard in [packages/test-utils/src/request-mocking.ts](packages/test-utils/src/request-mocking.ts) only throws when the outgoing request carries `x-mock-request`. When pattern-mismatched requests don't get `x-mock-request` forwarded, they silently hit the real backend. Hardening the guard to always throw for unmatched outbound requests during e2e runs is a separate improvement and is not required to unbreak the current tests.