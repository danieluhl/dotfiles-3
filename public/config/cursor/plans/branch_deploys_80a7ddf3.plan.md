---
name: branch deploys
overview: Add GitHub Actions deployment automation so merges to `master` deploy both Cloudflare Workers apps to the Wrangler `staging` env, and merges to `production` deploy both apps to the Wrangler `production` env.
todos:
  - id: add-deploy-workflow
    content: Create `.github/workflows/deploy.yml` with branch-based staging/production Wrangler deploy jobs.
    status: completed
  - id: wire-env-vars
    content: Expose Cloudflare credentials and web build variables to the workflow via GitHub environments.
    status: completed
  - id: verify-workflow
    content: Run local validation where possible and document any GitHub/Cloudflare setup that must be completed outside the repo.
    status: completed
isProject: false
---

# Branch-Based Wrangler Deploys

## Current State
- CI is only `.github/workflows/ci.yml`, which runs `pnpm check` on pushes to `master`/`main` and PRs.
- `apps/web/wrangler.jsonc` already defines `env.staging.name = "web-staging"` and `env.production.name = "web-production"`.
- `apps/api/wrangler.jsonc` already defines `env.staging.name = "api-staging"` and `env.production.name = "api-production"`.
- Existing app deploy scripts are close:
  - `apps/web/package.json`: `"deploy": "wrangler deploy"`
  - `apps/api/package.json`: `"deploy": "wrangler deploy --minify"`

## Implementation Plan
- Add a new GitHub Actions workflow at `[.github/workflows/deploy.yml](.github/workflows/deploy.yml)`.
- Trigger it on `push` to `master` and `production`; those push events are what GitHub emits after a PR merge.
- Use a small branch mapping step:
  - `master` -> `WRANGLER_ENV=staging`, GitHub environment `staging`
  - `production` -> `WRANGLER_ENV=production`, GitHub environment `production`
- Install the same toolchain as CI: `pnpm/action-setup@v4` with `10.20.0`, `actions/setup-node@v4` with `25.3.0`, and `pnpm install --frozen-lockfile`.
- Run `pnpm check` before deploying so direct branch pushes cannot deploy unchecked code.
- Deploy both apps with explicit Wrangler envs:
  - `pnpm --filter web deploy -- --env $WRANGLER_ENV`
  - `pnpm --filter api deploy -- --env $WRANGLER_ENV`
- Set workflow permissions narrowly, likely `contents: read`, unless the final action choice requires more.
- Configure workflow `concurrency` by branch/environment so only the latest deployment per environment runs.

## Required GitHub Configuration
- Add repository or environment secrets used by Wrangler:
  - `CLOUDFLARE_API_TOKEN`
  - `CLOUDFLARE_ACCOUNT_ID`
- Add environment-specific GitHub variables/secrets needed during the web build:
  - `VITE_WORKOS_CLIENT_ID`
  - `VITE_WORKOS_API_HOSTNAME`
  - optional `SERVER_URL`, if the web build needs it in CI
- Confirm required API Worker secrets already exist in Cloudflare for both `api-staging` and `api-production`:
  - `DATABASE_URL`
  - `LOGTAIL_SOURCE_TOKEN`
  - `CORS_ORIGIN`
  - `ENVIRONMENT`
  - `LOG_LEVEL`

## Verification
- Validate the YAML structure locally by review and, if available, `actionlint`.
- Verify package scripts still resolve to Wrangler commands with env args appended correctly.
- After merge to `master`, confirm both `web-staging` and `api-staging` deploy.
- After merge to `production`, confirm both `web-production` and `api-production` deploy.