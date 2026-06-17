---
description: Convert a plan into one or more ready-for-agent GitHub issues
argument-hint: "[plan file path or inline plan text]"
---

# Create Agent Task Issues

Convert an implementation plan into one or more GitHub issues that autonomous agents can pick up and complete.

## Input

<plan_input> #$ARGUMENTS </plan_input>

If the input is empty, ask the user for a plan file path or inline plan text before proceeding.

If the input looks like a file path, read that file completely. Otherwise, treat the input as the plan text. Review all references in the plan that are needed to make the resulting issues self-contained.

## Required Template

Before creating issues, verify the repository contains `.github/ISSUE_TEMPLATE/autonomous-agent-task.yml`.

Use that template's fields when drafting each issue:

- `What to build`
- `Acceptance criteria`
- `Blocked by`

Create every issue with both labels:

- `agent-task`
- `ready-for-agent`

If `gh` is unavailable, not authenticated, or cannot access the repository, stop and ask the user how they want to proceed. Do not silently create issues in another tracker.

## Split the Plan

Identify independently shippable tasks from the plan.

Create more than one issue only when each issue can be completed, reviewed, and verified independently. Keep tightly coupled work together instead of creating artificial slices. If the plan is too ambiguous to split safely, ask the user for clarification before creating issues.

For each issue:

1. Choose a concise title using the template prefix: `[Agent Task]: <task title>`.
2. Include enough context that an autonomous agent can start without reading the whole original plan.
3. Include relevant file paths, commands, constraints, non-goals, dependencies, and verification expectations from the plan.
4. Make acceptance criteria specific, testable, and formatted as checkboxes.
5. Use `Blocked by` for concrete dependencies, required decisions, credentials, access, or predecessor issues. If there are no blockers, write `- None`.

## Issue Body Format

Draft each issue body as:

```markdown
### What to build

[Desired outcome, context, and non-goals.]

### Acceptance criteria

- [ ] [Measurable completion check.]
- [ ] Tests or verification steps are documented.

### Blocked by

- None

```

## Create Issues

For each drafted issue, write the body to a temporary markdown file and create the GitHub issue:

```bash
gh issue create \
  --title "[Agent Task]: <concise task title>" \
  --label agent-task \
  --label ready-for-agent \
  --body-file <generated-body-file>
```

When one issue depends on another, create the prerequisite issue first. Then include the created issue number or URL in the dependent issue's `Blocked by` section.

After the issue is created, add a comment to the issue with only the text
"ready-for-agent". This triggers an agent to pickup the work.

## Final Response

After creating issues, report:

- The issue URLs.
- The recommended work order, if there is more than one issue.
- Any tasks from the plan that were intentionally not turned into issues and why.
