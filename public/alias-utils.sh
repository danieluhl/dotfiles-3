# Recycle bluetooth for when switching computers and reconnecting Glove80
bb() {
  local delay_seconds="${1:-2}"
  echo "Turning Bluetooth off..."
  blueutil --power 0
  sleep "$delay_seconds"
  echo "Turning Bluetooth on..."
  blueutil --power 1
  echo "Bluetooth recycled."
}

# 1. Helper function: Extracts "owner/repo" and "PR number" from a GitHub PR URL.
#    Sets global variables GH_PARSED_REPO and GH_PARSED_PR.
gh_parse_pr_url() {
  local url="$1"
  
  if [ -z "$url" ]; then
    echo "Error: Please provide a GitHub PR URL."
    return 1
  fi

  GH_PARSED_REPO=$(echo "$url" | sed -nE 's#.*github\.com/([^/]+/[^/]+)/pull/.*#\1#p')
  GH_PARSED_PR=$(echo "$url" | grep -oE '[0-9]+$')

  if [ -z "$GH_PARSED_REPO" ] || [ -z "$GH_PARSED_PR" ]; then
    echo "Error: Could not parse repository or PR number from URL."
    return 1
  fi
}

# 2. Approve function
gha() {
  gh_parse_pr_url "$1" || return 1

  local comment="${2:-LGTM! 🚀}"

  echo "Approving PR #$GH_PARSED_PR on $GH_PARSED_REPO..."
  gh pr review "$GH_PARSED_PR" -R "$GH_PARSED_REPO" --approve -b "$comment"
}

# 3. Squash and merge function
ghmerge() {
  gh_parse_pr_url "$1" || return 1

  echo "Squash-merging PR #$GH_PARSED_PR on $GH_PARSED_REPO..."
  gh pr merge "$GH_PARSED_PR" -R "$GH_PARSED_REPO" --squash --delete-branch
}
