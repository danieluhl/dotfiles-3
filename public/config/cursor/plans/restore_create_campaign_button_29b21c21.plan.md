---
name: Restore create campaign button
overview: The homepage's Create Campaign buttons are hidden because `currentTenant` is always null in the app bootstrap. Fix by defaulting `currentTenant` to the first `org` tenant when no explicit tenant id is provided. Confirmed no other page has a create-campaign entry point.
todos:
  - id: bootstrap-default-tenant
    content: In apps/org-next/src/server/app-bootstrap.ts, change the fallback so currentTenant defaults to the first `org` tenant when no tenantId is supplied
    status: pending
  - id: verify-buttons
    content: Confirm no other page has a create-campaign entry point (already verified in findings; no action) and that the homepage buttons now render under canCreateCampaign
    status: pending
  - id: verify-checks
    content: Run `pnpm typecheck` and `pnpm check` to confirm no regressions
    status: pending
isProject: false
---

## Root cause

The homepage still renders two Create Campaign buttons in [`apps/org-next/src/routes/_authed/index.tsx`](apps/org-next/src/routes/_authed/index.tsx):

- `+ New campaign` in the Active Campaigns header (line 99-110)
- `Create your first campaign` empty-state CTA (line 123-132)

Both are gated on `canCreateCampaign = currentTenant?.tenant_type === "org"` (line 57).

However, `currentTenant` is **never populated** in [`apps/org-next/src/server/app-bootstrap.ts`](apps/org-next/src/server/app-bootstrap.ts):

```35:58:apps/org-next/src/server/app-bootstrap.ts
async function fetchAppBootstrapData({
  tenantId,
}: {
  tenantId?: number;
} = {}): Promise<AppBootstrap | null> {
  const user = await fetchCurrentUser();
  if (user === null) {
    return null;
  }
  const tenants = await fetchTenants();

  const currentTenant = tenantId
    ? (tenants.find((tenant) => tenant.id === tenantId) ?? null)
    : null;
  // ...
}
```

No caller ever passes `tenantId`, so `currentTenant` is always `null`, so `canCreateCampaign` is always `false`, so neither button renders. The same null tenant also breaks the server-side `createCampaign` flow (both `-campaigns.ts::requireBootstrapWithTenant` and `server/campaigns.ts` early-return when tenant is null).

## Other pages (user asked to check)

Searched for `CreateCampaignModal`, `useCreateCampaign`, `openCreateCampaignModal`, "Create campaign", "New campaign" across `apps/org-next/src`. The only entry points to campaign creation are the two buttons on the homepage. The campaign detail page at [`apps/org-next/src/routes/_authed/campaigns/$campaignId.tsx`](apps/org-next/src/routes/_authed/campaigns/$campaignId.tsx) and the organizations pages have none. Nothing to remove elsewhere.

## Fix

Default `currentTenant` to the first `org` tenant when no explicit `tenantId` is provided, in [`apps/org-next/src/server/app-bootstrap.ts`](apps/org-next/src/server/app-bootstrap.ts):

```ts
const currentTenant = tenantId
  ? (tenants.find((tenant) => tenant.id === tenantId) ?? null)
  : (tenants.find((tenant) => tenant.tenant_type === "org") ?? null);
```

Why this is the right call:

- Makes the two existing homepage buttons render for any user with an org tenant (no UI changes needed).
- Makes `fetchCampaignsList`, `createCampaign`, and `getCampaignDetail` actually hit the org API with a real `tenant_id` — the end-to-end modal flow works.
- Matches the existing test contract in [`apps/org-next/tests/campaigns.spec.ts`](apps/org-next/tests/campaigns.spec.ts), which mocks `/tenants` with a single org tenant (id 42) and expects subsequent API calls to use `tenant_id=42` — that only passes if the bootstrap auto-selects that tenant.
- Preserves the vendor-only test (`vendor tenant does not see org create-campaign entry points on the homepage`): when `tenants` has no `org`, `currentTenant` stays null and the button stays hidden.

## Non-changes (explicit)

- No changes to [`apps/org-next/src/routes/_authed/index.tsx`](apps/org-next/src/routes/_authed/index.tsx) — the buttons are already correct; only their visibility condition was broken upstream.
- No new routes, no new components, no tenant switcher UI. Proper tenant selection/switching (URL- or cookie-based) is out of scope.
- No changes to `CreateCampaignModal`, `useCreateCampaign`, or the `-campaigns.ts` server functions.
- Not touching [`apps/org-next/src/components/app-header.tsx`](apps/org-next/src/components/app-header.tsx) — the hardcoded `currentTenantName = "test"` is a separate cosmetic issue.

## Verification

- `pnpm typecheck` and `pnpm check` should pass.
- Manually: load `/` as a user with an org tenant — both create-campaign buttons appear; clicking either opens the `CreateCampaignModal` dialog; submitting creates the campaign and navigates to `/campaigns/:id`.
- `tests/campaigns.spec.ts` should exercise the full modal flow (pre-existing WIP env issues aside).

## Docs

Per `apps/org-next/AGENTS.md`, check `docs/README.md`. It currently documents only the auth flow and does not mention tenant resolution. No doc change needed, though a one-liner about "bootstrap auto-selects the first org tenant when none is specified" could be added if desired — I'll skip unless you want it.