# Collapse PRs

Collapse every open pull request in this repo into a single "mega" branch and
PR. Walk the open PRs one at a time, merge each into a fresh integration
branch, resolve conflicts, capture before/after screenshots of the resulting
UI, and open one PR that summarizes all of the collapsed changes.

Use `gh` for every GitHub interaction. Never force-push to `main`/`master` and
never close or modify the original PRs unless I explicitly ask.

## 0. Preconditions

- Confirm `gh auth status` succeeds and `gh repo view --json nameWithOwner` works.
- Determine the default base branch:
  `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`.
- Make sure the working tree is clean (`git status --porcelain`). If it is dirty,
  stop and tell me — do not stash or discard anything.
- `git fetch --all --prune` so every PR head ref is available locally.

## 1. Enumerate open PRs

Pull the full list of open PRs, oldest first so older work lands before newer
work that likely builds on it:

```bash
gh pr list --state open --limit 200 \
  --json number,title,headRefName,baseRefName,author,isDraft,mergeable,url,additions,deletions,changedFiles \
  --jq 'sort_by(.number)'
```

- Skip draft PRs by default; list them as "skipped (draft)" in the summary.
- Only consider PRs whose `baseRefName` is the default base branch. Note any
  that target a different base as "skipped (non-base target)".
- If there are zero eligible PRs, report that and stop.
- Echo the ordered plan (number, title, author, head branch) before merging.

## 2. Create the integration branch

```bash
git switch <base>
git pull --ff-only
git switch -c collapse/open-prs-<YYYYMMDD>
```

## 3. Merge each PR, one at a time

For every eligible PR in order:

1. `git fetch origin pull/<number>/head` (or use `gh pr checkout` into a temp
   branch) and merge it into the integration branch with a descriptive message:
   `git merge --no-ff <pr-head> -m "Collapse #<number>: <title>"`.
2. If the merge conflicts:
   - Resolve conflicts faithfully, preserving the intent of both sides. Prefer
     keeping all functionality from every PR.
   - If a conflict is genuinely ambiguous or risks breaking behavior, stop and
     ask me rather than guessing.
   - After resolving: `git add -A` and commit the merge.
3. After each merge, sanity-check the build so failures are attributed to the
   right PR:
   - `pnpm install` (only if dependencies changed)
   - `pnpm run typecheck`
   - `pnpm run check`
   If a step fails, fix it if the fix is obvious and low-risk; otherwise record
   the failure against that PR and continue, noting it in the final summary.
4. Track per-PR status: merged cleanly / merged with conflicts / build broken /
   skipped, plus a one-line description of what the PR does.

## 4. Capture screenshots of the changes

Once everything is merged:

1. Start the app: `pnpm install` then `pnpm run dev` (serves on port 3000).
   Wait until it is reachable before capturing.
2. Use Playwright (Chromium is already installed via
   `pnpm run playwright:install`) to screenshot the routes/views touched by the
   collapsed PRs. Infer affected routes from the changed files; at minimum
   capture the home route and any route whose page/component files changed.
3. Save images under `.collapse-screenshots/` (git-ignored — add it to
   `.gitignore` if missing) using clear names like
   `<route-or-feature>.png`.
4. Stop the dev server when done.
5. Embed the screenshots in your chat response so I can review them, and upload
   them for the PR body (see next step).

## 5. Push and open the collapsed PR

1. Create a **Tracked work item** issue summarizing the collapse (apply `cap:
   maintenance`). You will reference it in the PR body.
2. Push the integration branch: `git push -u origin HEAD`.
3. Upload each screenshot as a release/issue asset or attach via the GitHub web
   markdown by committing them to a throwaway `gh` gist, then reference the
   returned URLs in the PR body. If asset upload is not possible, fall back to
   committing the screenshots into a `docs/collapse-screenshots/` folder on the
   branch and reference them with relative repo paths so they render in the PR.
4. Open the PR with `gh pr create` against the default base, using a HEREDOC body.
   The title must be a **Conventional Commit** (CI blocks merge otherwise), e.g.
   `chore(collapse): integrate <count> open PRs`:

   ```bash
   gh pr create --base <base> --head collapse/open-prs-<YYYYMMDD> \
     --title "chore(collapse): integrate <count> open PRs" \
     --body "$(cat <<'EOF'
   Refs #<tracking-issue>

   ## Summary

   This PR collapses the following open PRs into a single branch.

   ## Collapsed PRs
   - #<n> <title> — @<author> — <clean | conflicts resolved | build issue>
   - ...

   ## Skipped
   - #<n> <title> — <reason: draft / non-base target>

   ## Notes & follow-ups
   - <conflicts resolved, build failures, anything needing review>

   ## Test plan
   - [ ] pnpm run typecheck
   - [ ] pnpm run check
   - [ ] pnpm run build
   - [ ] Manual UI review of screenshots above
   EOF
   )"
   ```

   The `Refs #NN` line must use a keyword followed by whitespace then the issue
   number (not `Closes: #NN`).

5. Label the collapsed PR when the repo supports it:

   ```bash
   gh pr edit <collapsed-pr-number> --add-label agent-collapsed
   ```

## 6. Report back

Print the new PR URL and a concise table of every source PR with its final
status (merged clean / conflicts resolved / build broken / skipped). Do not
close the original PRs — leave that decision to me.
