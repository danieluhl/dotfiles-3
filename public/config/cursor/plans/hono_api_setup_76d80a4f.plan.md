---
name: Hono API Setup
overview: Build a modern Cloudflare Workers Hono starter for a public CRUD API using Neon Postgres, Drizzle, Zod-backed OpenAPI, Scalar API docs, Cloudflare security/rate-limit primitives, and shared Hono RPC types.
todos:
  - id: bootstrap-worker
    content: Bootstrap the Cloudflare Workers Hono TypeScript project and core scripts.
    status: completed
  - id: middleware-env
    content: Add typed Worker env, global middleware, error handling, CORS, and rate-limit scaffolding.
    status: completed
  - id: drizzle-neon
    content: Configure Drizzle schema, Neon HTTP client, migrations, and secret handling.
    status: completed
  - id: hello-crud
    content: Build Zod/OpenAPI contract-first Hello CRUD routes backed by Drizzle.
    status: completed
  - id: api-artifacts
    content: Expose OpenAPI JSON, Scalar docs, shared `AppType`, and typed client example.
    status: completed
  - id: verification-docs
    content: Add tests, typecheck workflow, README setup notes, and deployment checklist.
    status: completed
isProject: false
---

# Hono Cloudflare API Setup Plan

## Stack Decisions
- Runtime: Cloudflare Workers with Hono, generated from the official `create-hono` Cloudflare Workers template and exported as the Worker default app. Source: https://hono.dev/docs/getting-started/cloudflare-workers
- Database: Neon Postgres through Drizzle using `drizzle-orm/neon-http`, because Drizzle documents Neon HTTP as serverless-friendly and faster for single, non-interactive transactions. Source: https://orm.drizzle.team/docs/connect-neon
- Validation and schema: `@hono/zod-openapi` so Zod request/response schemas validate inputs and generate OpenAPI from the same route contracts. Source: https://hono.dev/examples/zod-openapi
- Docs UI: Scalar at `/reference`, reading the generated OpenAPI document from `/openapi.json`. Source: https://hono.dev/examples/scalar
- Shared types: export `AppType = typeof app` and include a typed `hono/client` example so consumers can use Hono RPC inference. Source: https://hono.dev/guides/rpc
- Package manager: use `pnpm` in commands unless you prefer npm. Latest package versions checked from npm: `hono@4.12.18`, `@hono/zod-openapi@1.4.0`, `zod@4.4.3`, `drizzle-orm@0.45.2`, `drizzle-kit@0.31.10`, `@neondatabase/serverless@1.1.0`, `wrangler@4.92.0`, `@scalar/hono-api-reference@0.10.16`, `vitest@4.1.6`, `@cloudflare/vitest-pool-workers@0.16.6`.

## Target Structure
- [`package.json`](package.json): scripts for `dev`, `deploy`, `typecheck`, `test`, `db:generate`, `db:migrate`, `db:studio`, and `cf-typegen`.
- [`wrangler.jsonc`](wrangler.jsonc): Worker entry, compatibility date, observability, required `DATABASE_URL` secret, and optional Cloudflare Rate Limiting binding.
- [`drizzle.config.ts`](drizzle.config.ts): migration config for Neon using local `.env` or `.dev.vars` loading for CLI commands.
- [`src/index.ts`](src/index.ts): small Worker entrypoint exporting the assembled app.
- [`src/app.ts`](src/app.ts): app composition, global middleware, health route, OpenAPI document, Scalar docs, error/not-found handlers.
- [`src/env.ts`](src/env.ts): Cloudflare binding types, including `DATABASE_URL`, optional `CORS_ORIGIN`, and optional rate limiter binding.
- [`src/db/client.ts`](src/db/client.ts): `createDb(databaseUrl)` factory using Neon HTTP + Drizzle.
- [`src/db/schema/hellos.ts`](src/db/schema/hellos.ts): `hellos` table with generated id, message, optional language, created/updated timestamps.
- [`src/features/hellos/`](src/features/hellos/): route contracts, Zod/OpenAPI schemas, and handlers for CRUD.
- [`src/lib/errors.ts`](src/lib/errors.ts): consistent public API error envelope.
- [`src/lib/middleware.ts`](src/lib/middleware.ts): security, CORS, request id, rate-limit, and JSON logging middleware.
- [`src/client.ts`](src/client.ts): tiny typed client export/demo for consumers using `hc<AppType>()`.
- [`test/`](test/): Vitest route tests using `app.request()` and mocked Worker env.
- [`docs/`](docs/): short setup notes, API contract notes, and deployment checklist.

## API Shape
- Health and metadata:
  - `GET /health` returns service status and version metadata.
  - `GET /openapi.json` returns OpenAPI 3.1 JSON.
  - `GET /reference` serves Scalar interactive docs.
- Hello resource CRUD:
  - `GET /api/v1/hellos?page=1&pageSize=20` returns paginated records.
  - `POST /api/v1/hellos` validates `{ message, language? }` and returns `201`.
  - `GET /api/v1/hellos/{id}` returns one record or a structured `404`.
  - `PATCH /api/v1/hellos/{id}` accepts partial updates.
  - `DELETE /api/v1/hellos/{id}` returns `204` and is idempotent.
- Error responses use one envelope everywhere: `{ error: { code, message, details? } }`.
- List responses are paginated from the beginning: `{ data, pagination }`.

## Implementation Phases
1. Bootstrap the Hono Worker project in-place with TypeScript, Wrangler, strict `tsconfig`, package scripts, `.gitignore`, `.dev.vars.example`, and Cloudflare type generation.
2. Add app composition and middleware: `secureHeaders()`, environment-driven CORS, request id, structured logging, route-level error handling, not-found handling, and optional Cloudflare Rate Limiting API integration. Sources: https://hono.dev/docs/middleware/builtin/secure-headers, https://hono.dev/docs/middleware/builtin/cors, https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/
3. Add Drizzle + Neon foundation: schema, client factory, migration config, generated migration, and setup docs for `wrangler secret put DATABASE_URL`. Sources: https://neon.com/docs/guides/drizzle, https://developers.cloudflare.com/workers/configuration/secrets/
4. Define the contract-first Hello API with Zod/OpenAPI schemas before handlers, then implement CRUD against Drizzle.
5. Expose public API artifacts: OpenAPI JSON, Scalar reference UI, exported `AppType`, and typed Hono client example.
6. Add verification: unit/integration route tests with Vitest and `app.request()`, typecheck, migration generation check, and a README walkthrough.

## Verification Plan
- Run `pnpm typecheck` to prove strict TypeScript and shared types work.
- Run `pnpm test` for route behavior, validation failures, not-found responses, and mocked Worker env.
- Run `pnpm db:generate` to verify Drizzle schema and migration config.
- Run `pnpm dev` and manually check `/health`, `/api/v1/hellos`, `/openapi.json`, and `/reference`.
- Document deployment steps: set `DATABASE_URL` as a Worker secret, apply migrations, then `pnpm deploy`.

## Pragmatic Future Hooks
- Leave auth out of the demo CRUD routes, but structure middleware so API key/JWT auth can be added per route group later.
- Prefer Cloudflare’s built-in Rate Limiting API over an in-process limiter for public API protection.
- Keep one versioned API prefix, `/api/v1`, while designing schemas for additive changes.
- Use Neon branches later for preview/test databases if CI or preview deployments are added.