---
name: Hono Org Refactor
overview: "Refactor the current Hono Cloudflare starter to follow the referenced `tasks-api` organization: route modules with separate index/routes/handlers/tests files, centralized `lib/create-app`, dedicated middlewares, pino logging, Stoker status/OpenAPI helpers, and Biome linting."
todos: []
isProject: false
---

# Hono Organization Refactor Plan

## Objective
Keep the existing Hono, Cloudflare Workers, Neon, Drizzle, Zod/OpenAPI, and Scalar behavior, but reorganize the codebase after the referenced `tasks-api` pattern. The main change is structural: routes become small modules, app setup moves into `lib/create-app`, common handlers move into `middlewares`, status codes/OpenAPI helpers use Stoker, and lint/format uses Biome.

## Sources And Patterns
- Reference repo structure: `src/lib/create-app.ts`, `src/app.ts`, `src/routes/index.route.ts`, and `src/routes/tasks/tasks.{index,routes,handlers,test}.ts` from `https://github.com/danieluhl/tasks-api`.
- Hono typed test client requires chained routes for inference: https://hono.dev/docs/helpers/testing
- Stoker provides Hono-friendly status constants, OpenAPI helpers, schemas, and default handlers: https://github.com/w3cj/stoker
- `hono-pino` provides Pino logging middleware, but its README notes edge runtime limitations for advanced Pino features: https://github.com/maou-shonen/hono-pino
- Biome setup uses `@biomejs/biome`, `biome.json`, `biome check --write`, and `biome ci`: https://biomejs.dev/guides/getting-started/

## Target Structure
- [`src/app.ts`](src/app.ts): compose app via `createApp()`, `configureOpenApi(app)`, and mount route modules in an array.
- [`src/lib/create-app.ts`](src/lib/create-app.ts): expose `createRouter()`, `createApp()`, and `createTestApp(router)` like the reference repo.
- [`src/lib/configure-openapi.ts`](src/lib/configure-openapi.ts): own `/openapi.json` and `/reference` registration.
- [`src/lib/types.ts`](src/lib/types.ts): shared `AppBindings`, `AppOpenAPI`, and route handler aliases, including pino logger variable typing.
- [`src/openapi/default-hook.ts`](src/openapi/default-hook.ts): shared validation error hook returning `422`.
- [`src/middlewares/`](src/middlewares): split current middleware responsibilities into `index.ts`, `pino-logger.ts`, `not-found.ts`, `on-error.ts`, `cors.ts`, `rate-limit.ts`, and `security-headers.ts`.
- [`src/routes/index.route.ts`](src/routes/index.route.ts): root route returning API metadata using Stoker status constants and response helpers.
- [`src/routes/hellos/hellos.routes.ts`](src/routes/hellos/hellos.routes.ts): only OpenAPI route contracts and response schemas.
- [`src/routes/hellos/hellos.handlers.ts`](src/routes/hellos/hellos.handlers.ts): only Drizzle-backed handlers.
- [`src/routes/hellos/hellos.index.ts`](src/routes/hellos/hellos.index.ts): chained `.openapi()` registrations for typed inference.
- [`src/routes/hellos/hellos.test.ts`](src/routes/hellos/hellos.test.ts): colocated route tests using `testClient(createTestApp(hellosRouter), env)`.
- [`biome.json`](biome.json): formatter/linter config replacing any ESLint-style assumptions.

## Implementation Steps
1. Add dependencies and scripts: `hono-pino`, `pino`, `stoker`, and `@biomejs/biome`; add `lint`, `lint:fix`, `format`, and `check` scripts using Biome.
2. Introduce the app factory layer: create `src/lib/create-app.ts`, `src/lib/types.ts`, `src/openapi/default-hook.ts`, and `src/lib/configure-openapi.ts`; update `src/app.ts` to mount `[index, hellosRouter]` through the factory pattern.
3. Move middleware out of `src/lib/middleware.ts` into `src/middlewares/*`, replacing manual JSON logging with a Cloudflare-safe `hono-pino` middleware and keeping existing secure headers, CORS, request id, and rate limiting behavior.
4. Move the Hello API from `src/features/hellos/*` to `src/routes/hellos/*`, splitting schemas/contracts from handlers and using Stoker for status codes and OpenAPI response helpers.
5. Move tests from top-level `test/app.test.ts` into route-focused colocated tests, using Hono `testClient` where route inference works and keeping app-level smoke coverage for `/openapi.json` and `/reference` only if useful.
6. Update docs to describe the new route-module convention, middleware layout, Biome commands, Stoker usage, and pino logging behavior on Cloudflare Workers.
7. Remove obsolete files after their replacements are verified: `src/features/hellos/*`, `src/lib/middleware.ts`, and possibly `src/lib/openapi.ts` if fully replaced by `create-app` + `default-hook`.

## Verification
- Run `pnpm typecheck`.
- Run `pnpm test`.
- Run `pnpm db:generate` to confirm schema/migration config remains stable.
- Run `pnpm cf-typegen` if `wrangler.jsonc` or bindings change.
- Run `pnpm check` or equivalent Biome command.
- Run `pnpm audit --audit-level high` after dependency changes.
- Smoke test `pnpm dev` with `/`, `/health`, `/api/v1/hellos` validation, `/openapi.json`, and `/reference`.

## Risk Notes
- `hono-pino` documents edge-runtime limitations for advanced Pino features, so the implementation should avoid Node-only transports such as `pino-pretty` in the Worker runtime path.
- Stoker’s built-in validation error schemas may differ from the existing `{ error: { code, message, details } }` envelope; the refactor should preserve the current public error envelope unless we intentionally decide to adopt Stoker’s default `{ success, error }` validation shape.
- Route paths should remain `/api/v1/hellos`, `/health`, `/openapi.json`, and `/reference` unless explicitly changed.