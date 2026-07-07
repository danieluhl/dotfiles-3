Find any open PR that has review comments left by `cursor` or if given a branch
only focus on comments on that branch.

For each PR found start a separate cloud agent with instructions to checkout the PR branch, fix issues in PR comments, and push the changes.
