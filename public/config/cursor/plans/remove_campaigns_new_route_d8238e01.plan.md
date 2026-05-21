---
name: Remove campaigns/new route
overview: Delete the legacy `/_authed/campaigns/new` route file (create-campaign flow lives entirely in the homepage dialog) and fix the dead "Create campaign" onboarding-step button on the homepage so it opens the same dialog.
todos:
  - id: delete-route
    content: Delete apps/org-next/src/routes/_authed/campaigns/new.tsx
    status: completed
  - id: wire-onboarding
    content: In src/routes/_authed/index.tsx, change the onboarding step action button onClick from `() => null` to `openCreateCampaignModal`
    status: completed
  - id: update-test
    content: Remove the 'legacy /campaigns/new URL redirects to the homepage' test from tests/campaigns.spec.ts
    status: completed
  - id: verify
    content: Run the dev/build once so routeTree.gen.ts regenerates without the deleted route, and run campaigns.spec.ts
    status: completed
isProject: false
---

## Findings

- `apps/org-next/src/routes/_authed/campaigns/new.tsx` is a stub that only `throw redirect({ to: "/" })`. Creation already happens in [`create-campaign-modal.tsx`](apps/org-next/src/components/create-campaign-modal.tsx) opened from [`src/routes/_authed/index.tsx`](apps/org-next/src/routes/_authed/index.tsx).
- The homepage already has two working entry points: the `+ New campaign` button in the Active Campaigns header (lines 341-352) and the `Create your first campaign` empty-state button (lines 365-374). Both call `openCreateCampaignModal`.
- The onboarding-card step "Create your first campaign" renders a `Create campaign` action button (lines 298-309) whose handler is `onClick={() => null}` — this is the "missing" create-campaign button. It's the most visible CTA and does nothing.
- `tests/campaigns.spec.ts` has a test "legacy /campaigns/new URL redirects to the homepage" that will no longer be valid.
- `src/routeTree.gen.ts` is auto-generated (see `biome.jsonc` ignore and the TanStack router plugin); removing the source route file will regenerate it on the next dev/build run.

## Changes

### 1. Delete the legacy route file

- Delete [`apps/org-next/src/routes/_authed/campaigns/new.tsx`](apps/org-next/src/routes/_authed/campaigns/new.tsx).
- `src/routeTree.gen.ts` will regenerate automatically; no manual edits.

### 2. Wire the onboarding-step action to the dialog

In [`apps/org-next/src/routes/_authed/index.tsx`](apps/org-next/src/routes/_authed/index.tsx), replace the dead handler on the onboarding step button:

```tsx
onClick={() => null}
```

with:

```tsx
onClick={openCreateCampaignModal}
```

This reuses the existing `openCreateCampaignModal` helper, `CreateCampaignModal` instance, and `canCreateCampaign` gate already in the file — no new state, no new imports.

Only the "Create your first campaign" step has `action: "Create campaign"` in `sampleData.steps`, so only that row gets a working button. The "Complete verification" step keeps its `not_started` status badge and its own (currently placeholder) action.

### 3. Update the campaigns e2e spec

In [`apps/org-next/tests/campaigns.spec.ts`](apps/org-next/tests/campaigns.spec.ts):

- Remove the test `legacy /campaigns/new URL redirects to the homepage` (lines 144-168) — that contract goes away with the route.
- Leave the other three tests as-is; they exercise the modal flow which is unchanged.

### 4. Docs

Per `apps/org-next/AGENTS.md`, check `docs/README.md` for relevant updates. `docs/README.md` currently only documents the auth flow and does not mention campaign creation, so no doc change is needed.

## Out of scope

- No changes to `create-campaign-modal.tsx`, `use-create-campaign.ts`, or the server functions in `-campaigns.ts`.
- Not adding a header-level create button next to "Organization Settings". If you want that too, say so and I'll add it.
- Not preserving a redirect for `/campaigns/new`; after this change the URL will 404. Say so if you'd rather keep a redirect.