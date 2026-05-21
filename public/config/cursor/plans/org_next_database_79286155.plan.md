---
name: Org Next Database
overview: Add an org-next-owned Postgres database for app-specific state while keeping payment/domain data behind the existing anedot_next Rails API. This introduces a new server-only DB boundary in the UI monorepo, plus local DB infrastructure, migrations, schema validation, and test setup.
todos:
  - id: choose-boundary
    content: Confirm the ownership boundary for app-local state versus anedot_next domain/payment state.
    status: pending
  - id: add-db-tooling
    content: Add Drizzle, Postgres driver, migration scripts, and env validation to org-next.
    status: pending
  - id: add-local-postgres
    content: Add a reproducible local Postgres runner and documented database URLs for development and tests.
    status: pending
  - id: create-db-boundary
    content: Create server-only DB client, schema, migrations, and query modules under org-next.
    status: pending
  - id: migrate-first-setting
    content: Move one low-risk app preference to the database as the first end-to-end slice.
    status: pending
  - id: validate-and-document
    content: Add focused tests and update org-next docs with the new persistence architecture.
    status: pending
isProject: false
---

# Org Next Database Architecture

## Current Shape

`org-next` currently has no database layer. Durable domain data flows through the Rails backend via [`apps/org-next/src/server/org-api.server.ts`](apps/org-next/src/server/org-api.server.ts), authenticated by token cookies from [`apps/org-next/src/server/session.server.ts`](apps/org-next/src/server/session.server.ts). App preferences such as `selectedTenantId` and `theme` live in a signed `userSession` cookie through [`apps/org-next/src/server/user-session.ts`](apps/org-next/src/server/user-session.ts) and [`apps/org-next/src/server/user-session.server.ts`](apps/org-next/src/server/user-session.server.ts).

The sibling `anedot_next` Rails repo already owns its own Postgres database and payment/domain models. An `org-next` database should not add Rails models or Rails migrations for app-specific UI state unless that state becomes backend product/domain state.

## Proposed Boundary

Keep two explicit data sources:

```mermaid
flowchart LR
  browser[Browser] --> tanstack[org-next TanStack Start]
  tanstack --> authCookies[Signed auth cookies]
  tanstack --> orgDb[org-next Postgres]
  tanstack --> railsApi[anedot_next API]
  railsApi --> railsDb[anedot_next Postgres]
  railsApi --> payments[Payment providers]
```

`org-next` owns app-local data such as user UI settings, route preferences, dashboard configuration, feature walkthrough state, saved views, or other UI/productivity state that does not need to be part of the Rails payment/domain API.

`anedot_next` continues to own payment-related requests, tenant/domain objects, user identity as exposed through `/users/me`, tenant membership, and anything requiring payment or Rails-side authorization logic.

## Monorepo Pieces To Add

Add dependencies to [`apps/org-next/package.json`](apps/org-next/package.json):

- Runtime: `drizzle-orm`, a Postgres driver such as `postgres` or `pg`.
- Dev: `drizzle-kit` and likely `drizzle-zod` if you want generated Zod schemas from Drizzle tables.

Extend env validation in [`apps/org-next/src/env.ts`](apps/org-next/src/env.ts):

- `ORG_NEXT_DATABASE_URL` or `DATABASE_URL`, preferably `ORG_NEXT_DATABASE_URL` to avoid colliding with Rails conventions.
- Optional pool/tuning values only if needed later.

Add a server-only DB module under `apps/org-next/src/server/db/`, for example:

- `schema.ts`: Drizzle table definitions for app-owned tables.
- `client.server.ts`: create the Postgres client and `drizzle(...)` instance. This must stay server-only and should never be imported by route components or client-reachable modules.
- `queries/*.server.ts`: narrow query functions that enforce user scoping and tenant scoping.
- `migrations/`: generated SQL from `drizzle-kit`.

Use `createServerFn` as the public app boundary, matching current patterns in [`apps/org-next/src/server/user-session.ts`](apps/org-next/src/server/user-session.ts). Zod should validate server-function input; Drizzle/Zod schemas can validate insert/update shapes; route loaders and hooks call server functions, not the DB directly.

## Local Postgres Runner

Because this repo has no existing Docker Compose setup, adding Postgres would introduce new local infrastructure. The most reproducible setup would be a root-level Compose file or a small script-owned Compose file that runs only the `org-next` database, for example:

- Service name: `org-next-postgres`.
- Port: use a non-default host port such as `5434:5432` to avoid clashing with the Rails `anedot_next` local database.
- Database: `org_next_development`.
- Test database: `org_next_test`, either as a second database in the same container or created/reset by scripts.
- Env template entry in [`apps/org-next/.env.template`](apps/org-next/.env.template): `ORG_NEXT_DATABASE_URL=postgres://postgres:postgres@localhost:5434/org_next_development`.

Wire scripts into [`apps/org-next/package.json`](apps/org-next/package.json):

- `db:generate`: generate migrations from schema changes.
- `db:migrate`: apply migrations.
- `db:studio`: optional Drizzle Studio.
- `db:push`: optional for local prototyping, but migrations should be the reviewable path.

Root [`scripts/dev`](scripts/dev) could either stay focused on app processes and expect the DB to be started separately, or gain a separate `dev:db` flow. I would keep the DB start explicit at first so normal UI development does not unexpectedly manage containers.

## Testing Shape

For unit tests, keep pure schema/validation tests lightweight with Vitest. For query tests, use an isolated test database and reset it per test file or suite. Avoid replacing DB behavior with MSW, because MSW/RMP currently only covers HTTP calls to `anedot_next`.

For Playwright, choose one policy:

- Preferred for DB-backed UI state: run migrations against `org_next_test` before Playwright and clean app-owned rows per test.
- For tests not exercising DB-backed state: keep RMP for Rails API calls and seed only minimal `org-next` DB records when needed.

## First Feature Candidate

The cleanest first migration would be moving `userSession.theme` or another low-risk preference from the signed cookie into `org-next` Postgres. I would not immediately move `selectedTenantId` unless we are clear about cross-device behavior and tenant scoping, because today it is resolved against tenants from `anedot_next` in [`apps/org-next/src/server/app-bootstrap.ts`](apps/org-next/src/server/app-bootstrap.ts).

## Documentation

Update [`apps/org-next/docs/README.md`](apps/org-next/docs/README.md) with the new persistence boundary: what belongs in `org-next` Postgres, what remains in `anedot_next`, how local DB setup works, and the rule that DB modules are server-only.