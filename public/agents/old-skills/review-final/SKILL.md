---
name: review-final
description: "Reviews all changes on the current branch compared to the default branch (main or master). Use for a full branch review before opening a PR or merging. Prioritizes bugs, behavioral regressions, security issues, and missing tests. Triggers on \"review branch\", \"review final\", \"review for merge\", \"review before PR\", or \"full branch review\"."
---

# Review All Branch Changes

Review every change on the current branch since it diverged from the default branch (main or master). Includes both committed and uncommitted work — the full picture of what would land in a PR.

## Instructions

### Step 1: Detect the default branch and gather the diff

```bash
# Detect default branch (main or master)
git rev-parse --verify main >/dev/null 2>&1 && DEFAULT_BRANCH=main || DEFAULT_BRANCH=master

# Find the merge base (where this branch diverged)
MERGE_BASE=$(git merge-base $DEFAULT_BRANCH HEAD)

# Full diff of all branch changes (committed + uncommitted) vs the default branch
git diff $MERGE_BASE HEAD --stat
git diff $MERGE_BASE HEAD

# Also include any uncommitted work on top
git diff HEAD --stat
git diff HEAD
```

If the branch diff is empty (branch is identical to the default branch and no uncommitted changes exist), report "No changes on this branch to review" and stop.

### Step 2: Understand the branch

- Run `git log --oneline $MERGE_BASE..HEAD` to see the commit history and understand the narrative of the work.
- Read enough of each changed file to understand the surrounding code (function signatures, types, imports, callers).
- If workspace rules or AGENTS.md files exist, check them for project conventions that apply to the changes.

### Step 3: Review with this priority order

1. **Bugs** — Logic errors, off-by-one, null/undefined access, wrong variable, race conditions, broken control flow.
2. **Behavioral regressions** — Does the change accidentally break existing behavior? Are return types or API contracts changed without updating callers?
3. **Security** — Injection, leaked secrets, auth bypass, unsafe deserialization, missing input validation.
4. **Missing tests** — If the change adds or modifies logic, are tests added or updated? Are edge cases covered?
5. **Error handling** — Swallowed errors, missing catch blocks, generic catch without re-throw where needed.
6. **Style & conventions** — Only flag violations of project-specific rules (from AGENTS.md / workspace rules), not personal preferences.

### Step 4: Report findings

Use this output format:

```markdown
## Branch review: [branch name] vs [default branch]

**Commits:** [count]
**Files changed:** [count]

### Critical
- **[file:line]** — [description of bug/security issue]

### Warnings
- **[file:line]** — [description of regression risk or missing coverage]

### Nits
- **[file:line]** — [minor style/convention issue]

### Summary
[1-3 sentence overall assessment: is this branch ready to merge?]
```

Omit any severity section that has zero findings.

## Guidelines

- Do NOT make code changes unless explicitly asked. This is a read-only review.
- Review the FULL branch diff (committed + uncommitted), not just the latest commit.
- Keep findings actionable: include the file, line, and a concrete description.
- If changes look clean, say so. Don't invent issues to fill the report.
- Order findings by severity within each section (worst first).
- When a finding spans multiple commits, reference the final state of the code, not intermediate commits.
