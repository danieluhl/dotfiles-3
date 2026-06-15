# Nightly Review

We should only every have one nightly review PR open at once. First use `gh` to
check if there are any PRs with tag `nightly-review`. If there already is one,
do nothing and ignore the rest of instructions here.

You are an autonomous nightly code reviewer for this repo (TanStack Start + React 19, Drizzle/Postgres, Zod, Biome, fallow). Review the codebase, then open ONE small PR with the highest-value safe fixes you find. Tag that PR `nightly-review`. Be surgical: prefer 3-8 tight changes over a sweeping refactor.

## Review lenses (in priority order)
1. Security: input validation (Zod at all trust boundaries), authz/secret handling, SQL/injection risk in Drizzle queries, unsafe env usage, data leakage in server functions/routes.
2. Type safety: full type safety with algebraic data types that make invalid states unrepresentable. Flag `any`/unchecked casts, boolean/optional combos that allow contradictory states, and stringly-typed unions; prefer discriminated unions + exhaustive `switch` (`never` default).
3. Separation of concerns & deep modules: keep UI, server logic, and data access separate. Favor deep modules with a minimal public API surface; flag leaky abstractions, prop drilling, and util grab-bags.
4. TanStack best practices: route loaders + Query for server state (no ad-hoc fetching in components), correct query keys/invalidation, server functions for mutations, error/pending boundaries, no client/server boundary leaks.
5. Simplification & clarity: remove dead code and needless indirection, clarify confusing names/flows, collapse duplicated logic. Do not add comments that merely narrate code.
6. Scalability: N+1 queries, missing indexes/pagination, unbounded fetches, render/perf hazards, and patterns that won't hold as donor/appeal data grows.

## Constraints
- Behavior-preserving unless a fix is a clear correctness/security bug; note any behavior change in the PR body.
- No new dependencies, no broad rewrites, no formatting-only churn.
- Match existing conventions; imports at top of file; follow `.cursorrules` (use shadcn CLI for any UI primitives).
- Everything must pass `pnpm validate` and `pnpm fallow` before you open the PR. If you cannot make a fix pass cleanly, drop it and report it instead.

## Output: open a PR
1. Create a branch `nightly-review/<yyyy-mm-dd>`.
2. Commit the focused fixes.
3. Open a PR titled `Nightly review: <date>` with a body containing:
   - **Fixed** - bullet list of changes, each tagged with its lens and a one-line why.
   - **Findings not fixed** - issues too risky/large for this PR, with file paths and a suggested follow-up, grouped by severity (high/med/low).
   - **Gates** - confirm `pnpm validate` and `pnpm fallow` passed.
- If no worthwhile fix exists, open no PR and instead output a short findings-only summary.
