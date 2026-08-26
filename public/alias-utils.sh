# Recycle bluetooth for when switching computers and reconnecting Glove80
function bb
  set -l delay_seconds (test -n "$argv[1]" && echo $argv[1] || echo 2)
  echo "Turning Bluetooth off..."
  blueutil --power 0
  sleep $delay_seconds
  echo "Turning Bluetooth on..."
  blueutil --power 1
  echo "Bluetooth recycled."
end

# 1. Helper function: Extracts "owner/repo" and "PR number" from a GitHub PR URL.
#    Sets global variables GH_PARSED_REPO and GH_PARSED_PR.
function gh_parse_pr_url
  set -l url $argv[1]

  if test -z "$url"
    echo "Error: Please provide a GitHub PR URL."
    return 1
  end

  set -gx GH_PARSED_REPO (echo $url | sed -nE 's#.*github\.com/([^/]+/[^/]+)/pull/.*#\1#p')
  set -gx GH_PARSED_PR (echo $url | grep -oE '[0-9]+$')

  if test -z "$GH_PARSED_REPO"; or test -z "$GH_PARSED_PR"
    echo "Error: Could not parse repository or PR number from URL."
    return 1
  end
end

# 2. Approve function
function gha
  gh_parse_pr_url $argv[1]; or return 1

  set -l comment (test -n "$argv[2]" && echo $argv[2] || echo "LGTM! 🚀")

  echo "Approving PR #$GH_PARSED_PR on $GH_PARSED_REPO..."
  gh pr review $GH_PARSED_PR -R $GH_PARSED_REPO --approve -b "$comment"
end

# 3. Squash and merge function
function ghmerge
  gh_parse_pr_url $argv[1]; or return 1

  echo "Squash-merging PR #$GH_PARSED_PR on $GH_PARSED_REPO..."
  gh pr merge $GH_PARSED_PR -R $GH_PARSED_REPO --squash --delete-branch
end
