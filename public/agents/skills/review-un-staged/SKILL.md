---
name: review-un-staged
description: "Reviews only staged and unstaged changes on the current branch with a code review mindset. Use when you want a focused review of uncommitted work-in-progress before committing. Prioritizes bugs, behavioral regressions, security issues, and missing tests. Triggers on \"review my changes\", \"review unstaged\", \"review staged\", \"review wip\", or \"review uncommitted\"."
---

# Review Unstaged & Staged Changes

Review only the uncommitted (staged + unstaged) changes on the current branch. Ignore already-committed work. Focus on what the developer is about to commit.

## Instructions

### Step 1: Gather the diff

Run these commands to collect the uncommitted changes:

```bash
# Unstaged changes (working tree vs index)
git diff

# Staged changes (index vs HEAD)
git diff --cached

# Combined stat summary
git diff HEAD --stat
```

If both diffs are empty, report "No uncommitted changes to review" and stop.

### Step 2: Understand context

- Read enough of each changed file to understand the surrounding code (function signatures, types, imports).
- If workspace rules or AGENTS.md files exist, check them for project conventions that apply to the changes.

### Step 3: Review with this priority order

1. **Bugs** — Logic errors, off-by-one, null/undefined access, wrong variable, race conditions, broken control flow.
2. **Behavioral regressions** — Does the change accidentally break existing behavior? Are return types or API contracts changed without updating callers?
3. **Security** — Injection, leaked secrets, auth bypass, unsafe deserialization, missing input validation.
4. **Missing tests** — If the change adds or modifies logic, are tests added or updated?
5. **Error handling** — Swallowed errors, missing catch blocks, generic catch without re-throw where needed.
6. **Style & conventions** — Only flag violations of project-specific rules (from AGENTS.md / workspace rules), not personal preferences.

### Step 4: Report findings

Use this output format:

```markdown
## Review of uncommitted changes

**Files changed:** [count]

### Critical
- **[file:line]** — [description of bug/security issue]

### Warnings
- **[file:line]** — [description of regression risk or missing coverage]

### Nits
- **[file:line]** — [minor style/convention issue]

### Summary
[1-3 sentence overall assessment: is this safe to commit?]
```

Omit any severity section that has zero findings.

## Guidelines

- Do NOT make code changes unless explicitly asked. This is a read-only review.
- Do NOT review already-committed changes on the branch — only `git diff` and `git diff --cached` output.
- Keep findings actionable: include the file, line, and a concrete description.
- If changes look clean, say so. Don't invent issues to fill the report.
- Order findings by severity within each section (worst first).
