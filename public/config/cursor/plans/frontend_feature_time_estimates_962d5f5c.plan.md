---
todos: []
---

# Frontend Feature Time Estimates (Realistic: 1 Senior Engineer + Top-Tier Agent)

## Current Reality (assumptions baked into these estimates)

- **Stack**: React 18, TanStack Router/Query, Tailwind, **shadcn out-of-the-box primitives only** (no domain composites yet — payment-method form, address autocomplete, masked inputs, TipTap, CodeMirror, signature pad, file uploader, Konva venue editor, virtualized select all need to be built).
- **Backend**: not fully complete; **data model is changing**, requiring new shapes, new adapters, and new client-side logic. **Moderate API coordination tax** with the backend team — schema negotiations, blocked-on-backend cycles, contract iteration.
- **Team**: **one senior engineer steering one top-tier coding agent** (Cursor / Claude Code / similar) end-to-end.
- **Testing**: **complete Playwright user-flow tests added per feature**. This is non-trivial — ~20-45% adder on top of feature implementation depending on complexity.
- **Reference**: the existing `anedot-frontend` codebase serves as reference, but the data flow is being reworked for the new backend.

## Effective Multipliers (vs. the prior "AI ideal" estimates)

These are the *adders* that erode AI productivity in the current reality:

- **Backend churn / API coordination**: **+25-40%**. Schema iteration, waiting on endpoints, mock-then-rework cycles, breaking changes.
- **Playwright user-flow tests**: **+20-45%** depending on UI complexity (simple form ≈ +20%, multi-step wizard ≈ +30%, payment flow ≈ +35%, builder ≈ +45%).
- **No domain composites yet**: amortized into foundation below.

Net result: AI agents still help substantially on CRUD/tables (~3x speedup vs. human-only), but on payment integrations, KYC, and the Builder, the effective speedup shrinks to ~1.1-1.3x once you include API churn + Playwright.

---

## 0. Foundation (one-time, before features)

- **Domain composite components on top of shadcn primitives**:
  - Payment-method form (card/bank/ACH base): **4-6 days**
  - Smarty address autocomplete + zip lookup: **2-3 days**
  - Masked inputs (currency, phone, EIN, SSN, dates): **2-3 days**
  - TipTap `RichTextEditor` with custom extensions (`BoxNode`, link bubble): **3-5 days**
  - CodeMirror `CodeEditor`: **1-2 days**
  - `SignaturePadControl` (react-signature-canvas wrapper): **1 day**
  - `FileUploader` (react-dropzone wrapper + progress + validation): **1-2 days**
  - Konva `VenueEditor`: **3-5 days**
  - Virtualized infinite select (TanStack Virtual): **2-3 days**
  - Form composites (`FormSection`, `FieldArray`, conditional fields): **2-3 days**
  - `TableLayout` + `FilterDrawer` pattern (TanStack Table + shadcn): **2-4 days**
  - Composites subtotal: **23-37 days**
- **State / data layer** (TanStack Query patterns, query-key factories, `usePermissions`, `usePagination`, `useQueryFilters`, `useRequestToast`, `useFileUploader`, Zustand `useAuthStore`): **10-16 days**.
- **API client / SDK glue** (axios/ky wrapper, interceptors, CSRF, 401 redirect; **friction adder for backend-in-flux**): **5-8 days**.
- **Domain types** (will churn with backend; build a flexible mapping layer): **5-8 days**.
- **Utils** (formatters, role checks, `usePlaid`, `useFormHistory`, `FeatureFlaggedComponent`): **4-7 days**.
- **Route guards / Rollbar / shell polish on the existing scaffold**: **3-5 days**.
- **Playwright infrastructure** (config, fixtures, auth helpers, page-object pattern, MSW or backend-stub mode, CI integration, visual regression baseline): **4-6 days**.

**Foundation total: ~54-87 days.**

---

## Per-Feature Estimates

For each feature: *prior modern-stack human estimate* → **realistic AI-assisted estimate**, with implementation, API coordination, and Playwright tests folded in.

### 1. Action Pages — Builder
- 130-185 → **120-175 days**. Why: 0.94x effective multiplier. AI accelerates panel chrome but Builder is the worst case for the realism adders — backend changes ripple through schema/preview, and **Playwright tests for a WYSIWYG with drag-drop + undo/redo + live preview are genuinely expensive (~30-50 days of test work alone)**.

### 2. Action Pages — Public Donor Page & Payments
- 75-110 → **70-105 days**. Why: 0.93x. Per-method (each includes Playwright with mocked vendor):
  - Card vault tokenization + ACH base: **6-10 days**
  - Plaid bank link: **5-7 days**
  - PayPal: **5-7 days**
  - Apple Pay (cert + merchant validation): **5-8 days**
  - Google Pay: **3-5 days**
  - OpenNode (Bitcoin redirect/callback): **3-5 days**
  - Cloudflare Turnstile: **2-3 days**
  - Kount device data: **2-3 days**
  - Page chrome, blocks, layouts, exit intent, upgrade funnel: **25-35 days**
  - Analytics + receipt polling + Rollbar: **3-5 days**
  - Backend coordination tax (new submission shape, polling contract): folded in above.

### 3. Action Pages — Confirmation, Submissions, Index, Products
- 18-28 → **6-10 days** (0.35x — pure CRUD).

### 4. Events Hub (admin)
- 20-28 → **11-15 days** (0.55x — ticketing + attendee + check-in have novel logic + multi-state Playwright flows).

### 5. Storefront
- 20-28 → **8-11 days** (0.40x).

### 6. Store Products (admin)
- 16-24 → **5-8 days** (0.33x).

### 7. Dashboard V1 (legacy, dockable)
- 15-22 → **6-9 days** (0.41x). **Strong recommend: drop in favor of V2.**

### 8. Dashboard V2
- 5-8 → **2-3 days** (0.41x).

### 9. Organization Application (KYC wizard)
- 38-55 → **30-44 days** (0.79x — Plaid IDV + bank link + document upload + 11-step Playwright happy-path + edge-case coverage).

### 10. Organization Setup (5-step wizard)
- 8-12 → **4-6 days** (0.51x).

### 11. Settings — Org & Account Configuration
- 79-118 → **26-39 days** (0.33x — heavy CRUD; agents do well, Playwright per sub-page is mostly form-fill happy paths).
  - Account setup (Org Info, Domains, Disclaimer, Brand, Custom Code, Finance Presets): **8-12 days**
  - Access (Users, Teams, Permission Lists, Connected Accounts): **8-12 days**
  - Finance (Bank Accounts via Plaid, Funds, Billing Agreements, Statements): **5-8 days**
  - Integrations directory + Integration Requests + API Key: **4-6 days**
  - Settings shell + nav: **1 day**

### 12. Admin (Staff Tools)
- 81-118 → **27-39 days** (0.33x).
  - Accounts list + AccountView (incl. Account Users + Billing Agreements): **6-9 days**
  - Donations + DonationView: **3-5 days**
  - Submissions + SubmissionView: **3-5 days**
  - Commitments + CommitmentView (recurrences + many state-change modals): **5-7 days**
  - Staff Users tools, Suspicious Activity, Custom Domains, Pages, Payouts, Transfers, Revenue Reports: **7-10 days**
  - Shared admin modals (void/refund/receipt/chargeback) + Playwright across them: **3-5 days**

### 13. Donor Application (donor-facing portal)
- 34-49 → **14-20 days** (0.40x). Includes onboarding wizard + commitment editing drawer + charge lookup; commitments need careful Playwright coverage.

### 14. User Profile
- 3-5 → **1-2 days** (0.33x).

### 15. Finance Suite
- 76-114 → **30-46 days** (0.40x).
  - Transactions (list/detail/edit, rich filters, export, refund/void): **5-8 days**
  - Entries (journal-style, mirroring filters, export, refund): **3-5 days**
  - Commitments (list, filters, export, view drawer, deactivate): **4-6 days**
  - Ledger (balance table, jump-to-date, export, row actions): **3-4 days**
  - Vendor Earnings (vendor-scoped table, filters, export, detail, print): **3-4 days**
  - **Virtual Terminal** (manual donation entry — schema, donor autocomplete, encryption, charge polling): **5-8 days** (logic-heavy)
  - **CSV Import** (modal wired from multiple pages, mapping, validation, bulk job tracking): **4-6 days**
  - Payouts + Transfers: **2-3 days**
  - Shared Finance components: **1-2 days**

### 16. Relationships (CRM)
- 18-25 → **6-8 days** (0.33x).

### 17. Crimson Terminal
- 10-15 → **9-13 days** (0.85x — payment submission + encryption + polling + Playwright for charge confirmation flow).

### 18. ISP Terminal
- 3-4 → **3-4 days** (0.85x).

### 19. OAuth Redirect
- 3-4 → **2-3 days** (0.50x — well-tested edge cases including the `blackbaud` special case).

### 20. A/B Testing (sub-feature inside Builder)
- 7-10 → **4-6 days** (0.55x). Already partially in the Builder estimate; broken out for visibility.

---

## Summary Totals (full feature parity with the existing app)

- **Foundation**: **54-87 days**
- **Sum of features (items 1-19)**: **~383-561 days**
- **Grand total**: **~437-648 days** (≈ **22-32 calendar months** for one engineer + agent at ~20 productive days/month)

For comparison:
- "AI ideal" (backend done, composites done, no Playwright): ~239-361 days
- **Realism cost** (backend churn + composites + Playwright): **~1.6-1.8x slower** than the AI-ideal scenario
- Still ~2x faster than the human-only modern-stack estimate (~804-1,189 days)

---

## What's Hardest — and Worth Cutting/Modifying for Faster Time-to-Market

Ranked by **calendar days saved** if cut. The savings reflect both implementation time AND Playwright tests AND API coordination removed.

### Tier 1 — Massive wins (60+ days each)

- **Replace the Builder WYSIWYG with template + form-driven config.** This is the #1 lever by a huge margin.
  - Today's Builder is real WYSIWYG with live preview, undo/redo, drag-drop blocks, TipTap with custom blots, A/B testing UI, per-page-type panels (donation/lead/storefront/event). It's **120-175 days** in this scenario, of which **~30-50 days is Playwright alone** because testing builders is hard (drag-drop assertions, preview-iframe sync, undo/redo invariants).
  - Cheaper alternative: 8-12 polished templates + structured forms for content/finance/form/workflows + an iframe preview that re-renders on save (no live drag-drop, no undo/redo).
  - **Savings: ~80-115 days.** Also dramatically reduces ongoing maintenance and bug surface.

### Tier 2 — Big wins (15-35 days each)

- **Cut day-one payment methods to Card + Plaid ACH.** Defer PayPal, Apple Pay, Google Pay, OpenNode/Bitcoin, Kount.
  - **Savings: 18-28 days** plus weeks of vendor calendar time (Apple Pay merchant cert, OpenNode KYC).
- **Replace the custom KYC wizard with a hosted vendor flow** (Persona, Stripe Identity, or Plaid IDV-only embedded). Keep just the pre/post-vendor screens.
  - **Savings: 18-30 days.**
- **Defer the Donor Portal entirely.** Donors get receipts via email + a hosted "manage my recurring gift" link.
  - **Savings: 14-20 days.**
- **Defer Storefront + Store Products** if e-commerce isn't core to the launch wedge.
  - **Savings: 13-19 days.**
- **Trim the Admin suite to just the entity views Operations actually needs in week one** (Accounts, Donations, Submissions). Defer Commitments deep-edit, Suspicious Activity, Revenue Reports, Custom Domains, Pages browser.
  - **Savings: 12-18 days.**
- **Trim the Settings suite.** Defer Connected Accounts, Custom Code, Custom CSS, Custom Domains, the Integrations directory (gate behind a "request integration" form), Donor Statements, Disallowed States.
  - **Savings: 10-16 days.**

### Tier 3 — Medium wins (5-15 days each)

- **Defer Events / tickets / attendee check-in:** **11-15 days.**
- **Defer Crimson + ISP Terminals** (specialty single-tenant entry points): **12-17 days.**
- **Defer Virtual Terminal + CSV bulk import** in Finance for v1: **9-14 days.**
- **Drop Dashboard V1**, keep V2 only: **6-9 days.**
- **Defer A/B Testing** in Builder: **4-6 days.**
- **Trim the Connected Accounts flows** (incoming/outgoing/pending/inactive): **5-8 days** (subset of Settings savings above).

### Tier 4 — Don't cut (core, security-sensitive, or compliance)

- **Card vault tokenization + recurring billing logic** (charge polling/retry).
- **Plaid bank link + IDV** (async/webhook nature).
- **Refund / void / chargeback flows** in Admin.
- **Permissions model** (`PermissionsRouteGuard` + per-route role gating).
- **Auth/session + 401 redirect** (subtle for both org-scoped and donor-facing routes).

These are the parts where the senior engineer's judgment matters most — agents will produce plausible code, but the failure modes are silent (security regressions, double-charges, accounting errors).

---

## Three Concrete Scenarios

### Scenario A — Full feature parity
- Foundation: **54-87 days**
- All features: **383-561 days**
- **Total: ~437-648 days (~22-32 months solo)**

### Scenario B — Lean MVP (Tier 1 + most of Tier 2 + most of Tier 3 cuts)
Cut the Builder WYSIWYG (-95 days), trim payments to Card + Plaid (-23 days), hosted KYC (-24 days), defer Donor Portal (-17 days), defer Storefront (-16 days), trim Admin (-15 days), trim Settings (-13 days), defer Events (-13 days), defer Terminals (-15 days), defer Virtual Terminal + CSV (-12 days), drop Dashboard V1 (-7 days), defer A/B testing (-5 days). Total cut: **~255 days off the midpoint**.

- **Total: ~190-285 days (~10-14 months solo)**.
- This is the path I'd recommend if the goal is shipping a viable competitor in one calendar year.

### Scenario C — Aggressive wedge (only Tier 1 + Tier 4 stays — most else deferred to phase 2)
Just: foundation + Action Pages (template-based) + Public Page (Card + Plaid only) + minimal Admin + Dashboard V2 + Org Application (hosted KYC) + Org Setup + minimal Settings + User Profile + OAuth Redirect.

- Estimated: **~135-200 days (~7-10 months solo)**.
- Trades feature parity for time-to-market; phase 2 backfills the deferred items.

---

## Calibration / Caveats

- **API coordination is a tax on calendar time, not just engineering time.** A blocked-on-backend day still counts as a day. The 25-40% adder is calibrated for "responsive backend team that can turn around contract changes in 1-3 days." If turnaround is slower, multiply features that touch new data shapes by 1.2-1.4x more.
- **Playwright tests catch real bugs but slow each feature.** If you instead ship with Vitest unit + manual QA + observability/Rollbar in production, shave another **15-25%** off totals — at the cost of more production regressions.
- The senior engineer's **steering quality** matters enormously. Most of the above assumes consistent prompting, rigorous code review, and willingness to discard agent output that's wrong. Without that discipline, multipliers slip 1.3-1.5x worse.
- Vendor calendar time (Apple Pay merchant cert, Plaid sandbox approval, OpenNode KYC) is **not** speedable; allow real weeks for those even if engineering is "done."
- A second engineer would roughly halve calendar time on the parallelizable features (everything except the Builder, which is hard to split).
