---
name: virtual-terminal app
overview: Create a new `apps/virtual-terminal` TanStack Start app on port `3211`, using the monorepo's existing workspace, Vite, TypeScript, Biome, and Fallow patterns while keeping the app empty except for a hello world root route.
todos: []
isProject: false
---

# Virtual Terminal App Plan

## Assumptions
- Build a minimal but `org-next`-shaped TanStack Start app: same Vite/TanStack/Tailwind/Nitro/React Query/static-analysis posture, but no auth, tenant bootstrap, Rollbar, RMP request mocking, Playwright fixture, or org API code.
- Start without Playwright e2e files unless you later want a browser smoke test. Static gates will be Biome, TypeScript, Vitest with `passWithNoTests`, and Fallow.
- `virtual-terminal` must not contain copied comments, package metadata, routes, env keys, tests, or strings that reference `org-next`. The repo can still keep its existing unrelated `org-next` references elsewhere.

## Files To