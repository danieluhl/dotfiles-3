---
name: Fix campaign create test
overview: The failing test is caused by `router.invalidate()` in the create-campaign modal triggering a cascade of loader re-executions (bootstrap + dashboard) for the current page BEFORE navigation, producing DOM churn that Playwright observes as "many page/dom refreshes" and delaying/blocking the URL change to `/campaigns/101`.
todos:
  - id: fix-modal
    content: "Remove `await router.invalidate()` from create-campaign-modal.tsx and reorder to: close dialog -> navigate"
    status: completed
  - id: cleanup-props
    content: Remove `router` prop from CreateCampaignModal component and its usage in index.tsx
    status: completed
  - id: verify-test
    content: Run the failing Playwright test to confirm it passes
    status: in_progress
isProject: false
---

# Fix campaign creation test failure

## Root cause

In [create-campaign-modal.tsx](apps/org-next/src/components/create-campaign-modal.tsx), after creating a campaign the code does:

```typescript
const campaign = await createCampaignFn({ data: { name: trimmedName } });
await router.invalidate();   // <-- problem
onOpenChange(false);
await navigate({ to: "/campaigns/$campaignId", ... });
```

`router.invalidate()` re-runs **all active route loaders** before navigation:
- `_authed` layout loader -> `getAppBootstrapData()` -> GET `/users/me` + GET `/tenants`
- Home page loader -> `getDashboardPageData()` -> `getAppBootstrapData()` (again) + `listCampaigns()`

This triggers a full re-render of the home page with fresh data while the dialog is still open. Then `onOpenChange(false)` causes another re-render (closing dialog + resetting form key via `useEffect`). Then `navigate()` starts yet another loader cycle for the target route. The combined effect is multiple rapid DOM updates that Playwright sees as "many page/dom refreshes" and the URL never settles on `/campaigns/101` within the timeout.

## The fix

### 1. Reorder operations in `create-campaign-modal.tsx`

Remove the `await router.invalidate()` before navigation. Navigate immediately after creating the campaign:

```typescript
const campaign = await createCampaignFn({ data: { name: trimmedName } });
onOpenChange(false);
await navigate({
  to: "/campaigns/$campaignId",
  params: { campaignId: campaign.id.toString() },
});
```

Navigation to `/campaigns/$campaignId` will naturally run the `_authed` layout loader and the campaign detail page loader, giving us fresh bootstrap data. The home page data will refresh automatically (via TanStack Router's staleness mechanism) when the user navigates back.

### 2. Remove `router` prop from `CreateCampaignModal`

Since `router.invalidate()` is no longer called, the `router` prop is unused and can be removed from:
- The `CreateCampaignModalProps` type in [create-campaign-modal.tsx](apps/org-next/src/components/create-campaign-modal.tsx)
- The `CreateCampaignModal` usage in [index.tsx](apps/org-next/src/routes/_authed/index.tsx) (remove `router={router}` and the `useRouter()` import if no longer needed)

### 3. No test changes needed

The test in [campaigns.spec.ts](apps/org-next/tests/campaigns.spec.ts) already mocks all the endpoints needed for the fixed flow:
- GET `/users/me` (for `_authed` layout loader during navigation)
- GET `/tenants` (for `_authed` layout loader during navigation)
- POST `/campaigns?tenant_id=42` (campaign creation)
- GET `/campaigns/101?tenant_id=42` (campaign detail page loader)

The `campaignsIndexPattern` mock (returning `[]`) was only needed because `router.invalidate()` was refreshing the home page before navigation. With the fix, it is still harmless but no longer exercised during the create flow.

## Why this is safe

- Navigation to a new route always re-runs its loader chain (`_authed` -> campaign detail), so fresh data is loaded for the target page.
- The home page uses `getDashboardPageDataFn` as its loader. When the user navigates back, TanStack Router will detect stale data and re-run the loader, picking up the new campaign.
- Other uses of `router.invalidate()` in the codebase (workspace creation, campaign name edit, organizations) are on pages where the user **stays on the same page** after the mutation, so they correctly need invalidation. The campaign create modal is unique in that it navigates away immediately.
