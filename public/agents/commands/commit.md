---
description: "Stages all changes and creates a well-crafted conventional commit message. Use when the user wants to commit their work, write a commit message, or says \"commit\", \"commit changes\", \"save my work\", or \"commit everything\"."
---

# Commit Changes

Stage all changes and create a single, well-crafted commit following conventional commit conventions.

## Instructions

### Step 1: Gather the changes

```bash
git diff --stat
git diff --cached --stat
git status --short
```

If there are no staged or unstaged changes, report "Nothing to commit" and stop.

### Step 2: Read the full diff

```bash
git diff
git diff --cached
```

Read the diffs carefully. Understand what changed and why before writing the message.

### Step 3: Stage everything

```bash
git add -A
```

### Step 4: Write the commit message

Compose a message following this format:

```
<type>(<scope>): <summary>

<details>
```

**Type** — choose the most accurate:

| Type | Use when |
|------|----------|
| `feat` | Adding new functionality |
| `fix` | Correcting a bug or broken behavior |
| `refactor` | Restructuring code without changing behavior |
| `perf` | Improving performance |
| `test` | Adding or updating tests only |
| `docs` | Documentation-only changes |
| `chore` | Maintenance, dependencies, config |
| `build` | Build system or toolchain changes |
| `ci` | CI/CD pipeline changes |

**Scope** — the primary area affected (e.g. `campaigns`, `auth`, `api`, `infra`, `dashboard`, `forms`). Derive from the file paths and domain, not the filenames themselves.

**Summary rules:**

- Present tense, active voice ("add", not "added" or "adds")
- No trailing period
- 120 character max for the entire line
- Be specific: describe **what** changed and **why**
- Prefer outcomes over mechanisms ("prevent duplicate submissions" not "add debounce to handler")
- Avoid vague words: "update", "improve", "misc", "changes", "stuff"
- Write as a principal-level engineer would — clear, precise, professional

**Details rules:**

- Convert low-level implementation details into clear engineering outcomes.
- Emphasize reliability, maintainability, scalability, developer experience, performance, or user impact when supported by the changes.
- Infer likely intent from filenames, diffs, tests, and architectural changes.
- Write in a concise but polished professional tone suitable for engineering leadership review.
- Avoid vague wording like “stuff”, “fixes”, or “changes”.
- Avoid fabricated metrics, business impact, customer claims, or performance improvements unless explicitly evidenced.
- Prefer explaining why the change matters, not just what changed.

Examples of good framing:

- "improve reliability of..."
- "reduce duplication in..."
- "streamline onboarding flow..."
- "strengthen type safety around..."
- "optimize rendering performance for..."
- "simplify extension points for future..."
- "standardize validation behavior across..."

### Step 5: Commit

Use a heredoc to preserve formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <summary>

<details>
EOF
)"
```

### Step 6: Confirm

Run `git status` and `git log --oneline -1` to confirm the commit was created, then report the result.

## Guidelines

- Never split into multiple commits — this skill creates exactly one commit for all current changes.
- Do not warn or ask for confirmation before committing. Just do it.
- Do not skip the `git add -A` step — always stage everything.
- Check for files that likely contain secrets (.env, credentials, tokens). If found, warn the user and do NOT commit those files.
