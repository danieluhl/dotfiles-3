---
name: pr-review
description: >-
  Single entry point for PR and code review workflows.
  Routes to Bugbot review, security review, PR babysitting, PR walkthrough canvas,
  the no-mistakes ship gate, or listing open PRs.
  After bugbot/security review, fixes high/critical issues from findings and PR
  comments, then pushes the fixes.
  Use when the user runs /pr-review, asks to review a PR or branch, review open PRs,
  run a code review, security review, babysit a PR, or wants a PR walkthrough.
user-invocable: true
---

# PR Review (router)

One front door for review work.
Do not invent a parallel review process, and do not call overlapping review skills unless this skill routes to them.

## Choose a route

If the user already named a route (or an obvious synonym), take it immediately.
Otherwise ask one single-select question with these options:

| Id | Label | When |
| --- | --- | --- |
| `bugbot` | Code review (Bugbot) | Default for "review this", "review the PR", "find bugs" |
| `security` | Security review | Auth, secrets, tenancy, injection, privilege concerns |
| `babysit` | Babysit open PR | Make an existing PR merge-ready (CI, comments, conflicts) |
| `canvas` | PR walkthrough canvas | Interactive HTML walkthrough of a GitHub PR |
| `ship` | Ship gate (`no-mistakes`) | Validate then push/PR/CI before landing |
| `list` | List open PRs | See what is open and pick one |

Defaults when intent is clear but no route is named:

- Bare "review" / "review this PR" / PR URL + "review" → `bugbot`
- "open PRs" / "what PRs need review" → `list`, then offer routes for a chosen PR
- "merge-ready" / "fix CI on the PR" / "triage review comments" → `babysit`
- "walk me through this PR" / "review canvas" → `canvas`
- "ship" / "validate before merge" / `/no-mistakes` → `ship`

## Execute the chosen route

### `bugbot`

Follow `~/.cursor/skills-cursor/review-bugbot/SKILL.md` exactly (Task `bugbot` subagent).
If the user pointed at a PR URL, number, or branch, check it out first per that skill.
After the subagent finishes, continue with **Fix high/critical issues** below.
That remediates step overrides Bugbot's default "do not fix unless asked".

### `security`

Follow `~/.cursor/skills-cursor/review-security/SKILL.md` exactly (Task `security-review` subagent).
Same checkout rules as Bugbot when a PR/branch is named.
After the subagent finishes, continue with **Fix high/critical issues** below.

### `babysit`

Follow `~/.cursor/skills-cursor/babysit/SKILL.md`.
Resolve the target PR from the current branch or the user's URL/number.
Babysit already triages comments and pushes fixes; do not run the post-review fix loop again.

### `canvas`

Follow the `pr-review-canvas` skill from the cursor-team-kit plugin.
Requires a GitHub PR URL or number.

### `ship`

Follow `~/.cursor/skills/no-mistakes/SKILL.md` (or `/no-mistakes`).
Prefer this over `review-and-ship` for the ship/validate gate.

### `list`

```bash
npx -y gh-axi pr list
```

If `gh-axi` is unavailable, use `gh pr list`.
Show open PRs briefly, then ask which PR and which route (`bugbot`, `security`, `babysit`, `canvas`) to run next.

## Do not use (unless the user names them)

These overlap this router and add noise:

- `code-review-and-quality` (addy checklist)
- `thermo-nuclear-code-quality-review` (harsh maintainability pass)
- `make-pr-easy-to-review` (history/description tidy)
- `review-and-ship` (prefer `ship` → no-mistakes)
- bare Task `code-reviewer` when Bugbot is available
- `/review` picker (this skill replaces it)

If the user explicitly asks for one of the above, run that skill and say you are bypassing the router for that request.

## After a review route finishes

### Summarize

Summarize the review in a few lines (keep Bugbot/security severity tables when present).

### Fix high/critical issues (`bugbot` and `security` only)

Always remediates High and Critical issues after those review routes.
Do not wait for the user to ask.

1. **Collect issues** from both sources:
   - Review subagent findings marked High or Critical (or equivalent: critical, high, blocker, P0/P1).
   - Unresolved PR review and discussion comments on the target PR that report High/Critical problems.
     Prefer `npx -y gh-axi` (or `gh`) and the `get-pr-comments` skill.
     Filter out resolved threads. Read comment bodies and locations only.
2. **Triage**: Fix valid High/Critical items. Skip Medium/Low unless the user asks.
   If a finding or comment is invalid or unclear, say so briefly and leave it unfixed.
3. **Fix**: Implement scoped code changes that address each accepted High/Critical item.
   Do not expand into unrelated refactors.
4. **Commit and push**: Commit the fixes (follow the user's/repo commit rules; do not amend unless those rules allow it), then push the branch to the remote so the PR updates.
   If there is no open PR yet, still push the branch and note that.
5. **Report**: List what was fixed, what was skipped (and why), and the push/PR status.
   Offer one optional next step only when useful (for example: `babysit` for remaining CI, or `ship`).
