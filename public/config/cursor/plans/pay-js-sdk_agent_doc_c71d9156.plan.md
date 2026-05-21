---
name: pay-js-sdk agent doc
overview: Add a single, copy-paste-ready markdown file to the subfico/pay-js-sdk repository that merges official README guidance with integration details discovered in org-next (TanStack Start server functions, render-token coupling, customer resolution with account scoping, headers/middleware), structured so a coding agent can implement a complete card + payment-intent flow without guesswork.
todos:
  - id: draft-md-structure
    content: Draft AGENT_INTEGRATION.md in pay-js-sdk with sections 1–12 (mission, prerequisites, mermaid, render-token invariant, client/server specs, customer pattern, framework snippet, types, troubleshooting, verification, README pointer)
    status: pending
  - id: readme-link-reconcile
    content: Add README link to new doc; reconcile README gaps (PAY_API_VERSION, customer list query with account_id) in same or follow-up PR
    status: pending
  - id: spot-check-org-next
    content: Final pass against org-next demo.tsx + payments.server.ts to ensure no implicit step is missing from the runbook
    status: pending
isProject: false
---

# Agent-oriented integration doc for pay-js-sdk

## Goal

Add a new markdown file in **[subfico/pay-js-sdk](https://github.com/subfico/pay-js-sdk)** (suggested name: `AGENT_INTEGRATION.md` at repo root, or `docs/agent-integration.md` if you prefer colocation with other docs) that is **self-contained**: a user copies the whole file into their agent harness with a one-line instruction (“implement this in my app”). The document must encode everything the human README already states **plus** what is implicit in real integrations (exemplified by [demo.tsx](apps/org-next/src/routes/_authed/campaigns/$campaignId/pages/demo.tsx) and [payments.server.ts](apps/org-next/src/server/payments.server.ts)).

## Audience and scope

- **In scope for v1 of the doc:** Credit-card payment-intent flow (`validateForm` → server creates payment intent → `confirmPaymentIntent`), including server-side customer create/resolve and required HTTP headers.
- **Out of scope for the step-by-step body (but linked):** Google Pay express flow, setup intents, appearance/theming, full PCI prose — defer to existing [README.md](https://github.com/subfico/pay-js-sdk/blob/main/README.md) with explicit section anchors.

## Content outline (what to spell out)

### 1. Mission block (top of file)

- One paragraph: deliver a **working** checkout slice — iframe renders, user can pay in sandbox, success/error surfaced in UI.
- Explicit **non-goals** (e.g., production hardening, recurring billing) to prevent scope creep.

### 2. Prerequisites checklist (from README + tightened)

Copy the README’s three artifacts (**render token**, **API key**, **account ID**) and add:

- **Environment consistency:** sandbox vs production must match across dashboard origin (e.g. `dashboard-sandbox` vs `dashboard`), API base URL, API key, and render token (README already notes this; repeat here as a hard requirement).
- **Render token constraints:** allowed origins must include the app’s URL(s); `allowed_payment_method_types` must include `card` for the card iframe; amount limits implied by the token must cover test amounts.
- **Security:** API key only on the server; render token may be sent to the browser (document safe patterns vs anti-patterns — see §8).

### 3. Architecture diagram (mermaid)

A small flowchart: **Browser** (`SubFiCreditCardPaymentMethodForm` + ref) ↔ **App backend** (`createPayApiClient` + API key) ↔ **SubFi Pay API**. Label the two token roles: **render JWT** (iframe config) vs **embed JWT** (`data.token` from `POST /payment_intents`).

### 4. Critical invariant (implicit in org-next, easy to miss)

Spell out explicitly:

- The **`X-Render-Token` HTTP header** used when calling `POST /payment_intents` **must be the same render-token string** passed as `renderToken` to `SubFiCreditCardPaymentMethodForm` for that checkout session.

The README shows `X-Render-Token` on the server client ([README server example](https://github.com/subfico/pay-js-sdk/blob/main/README.md)); it does not emphasize strongly enough that **per-session** integrations should thread the **same** token the iframe uses (org-next does this by passing `renderToken` into [`createPaymentIntent`](apps/org-next/src/server/payments.server.ts)). Alternative valid pattern: static render token in server env **if** it is identical to the client iframe token — document both patterns and when each applies.

### 5. Ordered client sequence (numbered)

Mirror README steps 3–7 but make them **machine-checkable**:

1. `validateForm({ iframeRef })` — if false, stop and show validation message.
2. Call backend — must return the **embed token string** (`POST /payment_intents` response `data.token`).
3. `confirmPaymentIntent({ iframeRef, token })` — note it returns `void`; completion is via `onPaymentIntentConfirmationSucceeded` / `onConfirmationFailed`.
4. Required props: `onConfirmationFailed`; wire success handler for real UX (README uses `console.log` as placeholder).

Include **ref discipline** (already in README “Notes and potential gotchas”): one ref shared by the component, `validateForm`, and `confirmPaymentIntent`.

### 6. Server implementation specification

Consolidate README server sections into a single **header matrix** the agent must implement:

| Concern | Mechanism |
|--------|-----------|
| Base URL | `PAY_API_BASE_URL_SANDBOX` / `PAY_API_BASE_URL_PRODUCTION` or env-driven URL matching environment |
| Auth | `X-Api-Key` |
| Version | `params.header["X-Api-Version"]` — **always use exported `PAY_API_VERSION`** from `@subfico/pay-js-sdk/api` (do not hardcode; README text may say `"1"` but the SDK exports the canonical value — the agent doc should defer to the package constant to avoid drift). |
| Account | `X-Account-Id` on `POST /payment_intents` (and setup intents if extended later) |
| Render token | `X-Render-Token` matching iframe session (§4) |
| Idempotency | Fresh `X-Idempotency-Key` per mutating request — README middleware pattern; org-next sets it on **every** request in middleware ([payments.server.ts](apps/org-next/src/server/payments.server.ts)); document README’s optional GET exemption vs org-next’s simpler “always set” approach |

**Request body shape:** `POST /payment_intents` with `payment_intent: { ...CreatePaymentIntentInput, customer_id }` after customer resolution.

**Response:** Backend returns **only** what the browser needs for confirmation — the **embed JWT string** (`data.token`), not raw card data.

### 7. Customer create/resolve pattern (README + org-next delta)

The README’s `findOrCreateCustomer` example posts `body: { customer: requestBody }`. Production-style code should:

- Include **`account_id`** on create (scoped to the merchant account), as in org-next’s merge: `account_id: requestBody.account_id ?? accountId`.
- On **422**, list customers with **`email` and `account_id`** in query (org-next); the README’s list example only shows `email` — **call out this gap** so multi-tenant agents don’t resolve the wrong customer.

### 8. Framework-shaped example (optional subsection)

Add a short **TanStack Start**-shaped snippet (not required for all readers, but encodes lessons from demo.tsx):

- Server-only API wrapper (`createServerOnlyFn` or equivalent) so `SUB_API_KEY` never ships to the client.
- Client-callable server function (`createServerFn`) that validates input (e.g. email) and calls `createPaymentIntent`.
- Loader or env surface for **`renderToken`** to the client (prefer env var like `VITE_*` / framework equivalent — contrast with **demo anti-pattern**: hardcoded JWT in source in [demo.tsx](apps/org-next/src/routes/_authed/campaigns/$campaignId/pages/demo.tsx) should be described as **sandbox-only demo**, not production).

Also mention generic alternatives in one line: **Route Handler**, **Express**, **Rails controller** — same server contract.

### 9. Types and imports (reduce confusion)

README partially says “derive types from `components['schemas']`” while the SDK also re-exports OpenAPI types via `export *` from the api entry. Instruct agents to:

- Prefer **`CreatePaymentIntentInput`** from `@subfico/pay-js-sdk/react` for client/server payload typing where convenient (as in demo).
- Import **`createPayApiClient`**, **`PAY_API_VERSION`**, and schema types (`Customer`, `CreateCustomerInput`, etc.) from `@subfico/pay-js-sdk/api` as needed — align with whatever the published `dist/api.d.ts` exports for the release.

### 10. Troubleshooting table (for one-shot recovery)

| Symptom | Likely cause |
|--------|----------------|
| Iframe blank | Origin not allowed on render token; HTTPS/localhost mismatch |
| API errors / auth | API key environment doesn’t match base URL (sandbox vs prod) |
| Confirmation fails / mismatched session | `X-Render-Token` on server ≠ `renderToken` on iframe |
| Customer 422 / wrong user | Missing `account_id` on create or list |

### 11. Verification checklist

- Build passes; no API key in client bundle (static analysis hint: grep for `X-Api-Key` in client dirs).
- Manual sandbox: complete a small card payment; observe success callback or structured error from `onConfirmationFailed`.

### 12. Relationship to existing README

End with: “This file is an **integration runbook**; the [README](https://github.com/subfico/pay-js-sdk/blob/main/README.md) remains the **full product/SDK reference** (React API tables, appearance variables, Google Pay, setup intents, PCI narrative).”

Update **pay-js-sdk** `README.md` with one short paragraph + link to the new doc so discoverability is not limited to agent users.

## Repo-specific follow-up (pay-js-sdk)

- After drafting, **reconcile any README inaccuracies** discovered while writing (e.g., `PAY_API_VERSION` value, `findOrCreateCustomer` query params) — either fix README in the same PR or file a follow-up; the agent doc should reflect **correct** integration truth even if README lags briefly.

## Docs note for org-next

Per [AGENTS.md](apps/org-next/AGENTS.md), if you later document org-next’s SubFi env vars or payment flow in `apps/org-next/docs/`, do that in a **separate change**; this plan targets **only** the subfico repo artifact unless you explicitly expand scope.
