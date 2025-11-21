#!/usr/bin/env bash

# Usage:
#   ./org-commits-yesterday.sh ORG USERNAME
#
# Example:
#   ./org-commits-yesterday.sh anedot dan

ORG="anedot"
USER="$2"

if [ -z "$ORG" ] || [ -z "$USER" ]; then
  echo "Usage: $0 ORG USERNAME"
  exit 1
fi

# Yesterday in YYYY-MM-DD format
YESTERDAY=$(date -v -1d +%F)

echo "📅 Yesterday: $YESTERDAY"

echo "🔍 Fetching commits for $USER in $ORG on $YESTERDAY..."
echo

# GitHub API preview header is required for commit search
RESULTS=$(gh api \
  -H "Accept: application/vnd.github.cloak-preview" \
  "search/commits?q=org:$ORG+author:$USER+committer-date:$YESTERDAY" \
)

echo "$RESULTS" | jq -r '
  .items[]? |
  "Repo: \(.repository.full_name)\n" +
  "SHA: \(.sha)\n" +
  "Message: \(.commit.message)\n" +
  "Date: \(.commit.committer.date)\n" +
  "URL: \(.html_url)\n" +
  "----------------------------------------"
'
