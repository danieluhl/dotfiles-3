---
description: Generate a commit message for the staged changes and commit them
---

Use `git diff --name-status --cached` to see my latest staged changes then
generate a single-line Git commit message using Conventional Commits format.

Requirements:

- Format: <type>(<scope>): <concise, descriptive summary>
- Use an appropriate type (feat, fix, refactor, perf, test, docs, chore, build, ci)
- Scope should reflect the primary area affected (e.g. action-pages, api, auth, infra)
- Use present tense, active voice, no trailing punctuation
- Be clear, specific, and professional, as written by a principal-level engineer
- Focus on what changed and why, not implementation details
- Avoid vague language (update, improve, misc)
- Prefer outcomes over mechanisms (e.g. “prevent race condition” over “add mutex”)
- Do not exceed 120 characters total

Finally, commit my changes using the commit message.
