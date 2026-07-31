1. Do `git fetch` then checkout the branch provided or use the current branch if none provided.
2. Do `git rebase origin/main` if we are not already in a merge/rebase, otherwise do nothing
3. Resolve any conflicts and do `git rebase --continue` 
4. Continue fixing any conflicts and continue until the rebase is complete.
5. Push the changes `git push --force-with-lease`
