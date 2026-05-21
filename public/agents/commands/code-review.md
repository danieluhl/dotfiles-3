---
description: Do a code review of diff of `main`
---

Look at the changes between this branch and `main` to see my pr changes and
conduct a code review.

Review goals:

- Identify the most important bugs, edge cases, or logical pitfalls
- Highlight small, high-leverage improvements that make the code easier to read, reason about, or modify
- Evaluate whether the changes correctly meet the intended business requirements and user impact

Constraints:

- Do NOT suggest large refactors or architectural changes
- Do NOT comment on linting, formatting, naming style, or test coverage
- Do NOT propose changes unrelated to the intent of the diff
- Assume existing patterns and structure are intentional unless clearly harmful

Review style:

- Prioritize severity and impact over exhaustiveness
- Explain why an issue matters (risk, correctness, maintainability)
- Be concise, direct, and professional (principal-level engineer tone)
- Prefer actionable suggestions over abstract critique

Output format:

- Use bullet points
- Group feedback by severity: Critical, Important, Nice to have
- If no issues exist in a category, omit it
