---
name: github-summary
description: Summarize github activity for the last week
---

# GitHub Summary

Use the `gh` CLI to generate a fast weekly engineering activity digest.

## Goal

- Look at each teammate's GitHub activity across the Anedot organization over the last 7 days
- Keep it brief
- Focus on what got done from an engineering and product perspective
- Minimize commands, runtime, and token usage
- Do not inspect repositories one by one unless absolutely necessary

## Scope

- Organization: `anedot`
- Team members:
  - `alkamin`
  - `danieluhl`
  - `jin-ahn`
  - `jnwheeler44`
  - `josephhur`
  - `joshuabreland`
  - `meastman`
  - `nikkypx`
  - `paultwo`
  - `persianturtle`
  - `rkuenneke`
  - `smoil`
  - `strong-code`
  - `tconst`

## Rules

- Prefer `gh search prs` and `gh search issues`
- Use org-level search with `org:anedot`
- Use `--json` output only
- Do not run per-repo commands
- Do not collect extra fields you do not need
- Do not summarize before gathering data
- Do not fabricate product impact; infer conservatively from PR and issue titles only
- Prefer two org-level search calls total, not one search call per teammate
- Add `--sort updated --order desc` so results are time-ordered instead of best-match ranked

## Commands

Compute the cutoff date with a cross-platform command:

```bash
SINCE=$(python3 -c "from datetime import datetime, timedelta, timezone; print((datetime.now(timezone.utc) - timedelta(days=7)).date().isoformat())")
```

Use one org-level PR search across all teammates:

```bash
gh search prs "org:anedot updated:>=$SINCE (author:alkamin OR author:danieluhl OR author:jin-ahn OR author:jnwheeler44 OR author:josephhur OR author:joshuabreland OR author:meastman OR author:nikkypx OR author:paultwo OR author:persianturtle OR author:rkuenneke OR author:smoil OR author:strong-code OR author:tconst)" --limit 100 --sort updated --order desc --json number,title,url,repository,updatedAt,state,author
```

Use one org-level issue search across all teammates:

```bash
gh search issues "org:anedot updated:>=$SINCE (author:alkamin OR author:danieluhl OR author:jin-ahn OR author:jnwheeler44 OR author:josephhur OR author:joshuabreland OR author:meastman OR author:nikkypx OR author:paultwo OR author:persianturtle OR author:rkuenneke OR author:smoil OR author:strong-code OR author:tconst)" --limit 100 --sort updated --order desc --json number,title,url,repository,updatedAt,state,author
```

If the search query becomes too long or results are obviously truncated, split the teammate list into two grouped searches per resource type. Do not fall back to per-repo commands.

## Synthesis

After gathering results:

- Group PRs and issues by `author.login`
- For each person, write 1 to 3 short bullets max
- Focus on:
  - what they shipped or moved forward
  - whether work appears product-facing, infra or platform, docs, or maintenance
  - whether they had no visible activity
- Prefer PRs over issues when both exist
- If titles are vague, say the activity was unclear rather than guessing
- Ignore bots and obvious noise

## Output Format

```markdown
## Weekly GitHub team digest

- Name
  - PR count: N
  - Issue count: N
  - 1 to 3 bullets summarizing apparent work

## Overall themes

- 3 to 5 bullets on major patterns across the team
```

Keep the whole output compact and high-signal.
