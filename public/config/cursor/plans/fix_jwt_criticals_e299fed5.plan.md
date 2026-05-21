---
name: Fix JWT Criticals
overview: Fix the two critical JWT issues by removing tracked local secrets from commit scope and hardening the Cognito local-development bypass so it cannot run in production.
todos:
  - id: remove-env-secret
    content: Remove the real-looking local JWT secret from tracked `.env` changes and document placeholders instead.
    status: completed
  - id: production-guard
    content: Guard `ANEDOT_LOCAL_DEV` so local JWT validation cannot enable in production.
    status: completed
  - id: focused-test
    content: Add focused coverage for the production fail-closed behavior or equivalent validator behavior.
    status: completed
  - id: verify
    content: Run focused Cognito tests and inspect the final diff for secrets.
    status: completed
isProject: false
---

# Fix JWT Critical Issues

## Scope
Address only the two critical findings from the uncommitted review:

- Tracked `.env` contains a real-looking `LOCAL_DEV_JWT_SECRET`.
- `ANEDOT_LOCAL_DEV=true` can enable the HS256 bypass in any Rails environment.

## Plan

1. **Remove secret-bearing `.env` changes from the commit path**
   - Do not commit the new `LOCAL_DEV_JWT_SECRET` value in [`.env`](.env).
   - Move local-dev examples into a non-secret template or docs location, such as [`.env.example`](.env.example) if the repo already uses one, or [docs/cognito-testing.md](docs/cognito-testing.md).
   - Use placeholder values only, for example `LOCAL_DEV_JWT_SECRET="replace-with-shared-local-secret-at-least-32-chars"`.
   - Check whether `.env` should be ignored by git. If it is currently tracked intentionally, keep it free of secrets and only store placeholders.

2. **Fail closed for local-dev JWT validation in production**
   - Update [config/initializers/cognito.rb](config/initializers/cognito.rb) so `local_dev` can only become true outside production.
   - Prefer an explicit environment guard near the config source:

```ruby
local_dev_enabled = !Rails.env.production? && ENV["ANEDOT_LOCAL_DEV"] == "true"
```

   - Set `local_dev: local_dev_enabled` in `Rails.application.config.cognito`.
   - Optionally raise during boot if production has `ANEDOT_LOCAL_DEV=true`, so misconfiguration is noisy instead of silently ignored.

3. **Cover the guard with a small test**
   - Add or extend an initializer/config test if the project has a pattern for initializer tests.
   - If there is no clean initializer-test pattern, add coverage at the validator level by temporarily setting `Rails.application.config.cognito` to production-like `local_dev: false` behavior and proving HS256 tokens are not accepted unless `local_dev` is true.
   - Keep this targeted; no need to broaden into the non-critical access-token claim behavior unless you want to address warnings too.

4. **Verify before commit**
   - Run the focused Cognito tests:

```bash
bin/rails test test/services/cognito_jwt_validator_test.rb test/controllers/concerns/cognito_jwt_authentication_test.rb
```

   - Re-check uncommitted diff to ensure no real secret remains:

```bash
git diff -- .env config/initializers/cognito.rb test/services/cognito_jwt_validator_test.rb
```

## Recommended Outcome
The final diff should keep local development usable with explicit placeholders, while production cannot accept locally signed HS256 JWTs even if `ANEDOT_LOCAL_DEV=true` is accidentally present.