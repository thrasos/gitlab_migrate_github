#!/bin/bash
set -uo pipefail

TOKEN="YOUR_TOKEN"
GITLAB_DOMAIN="https://gitlab.com"

# Get the number of pages (issue #6: validate before looping)
TOTAL_PAGES=$(curl -sf --head --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100" | grep -i "x-total-pages" | tr -d '\r' | awk '{print $2}')

if ! [[ "$TOTAL_PAGES" =~ ^[0-9]+$ ]]; then
    echo "Failed to read X-Total-Pages (bad token, network error, or wrong domain?)" >&2
    exit 1
fi

# Loop through each page and clone the repos
for ((i=1; i<=TOTAL_PAGES; i++)); do
    echo "Fetching page $i"
    curl -sf --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100&page=$i" | jq -r '.[].ssh_url_to_repo' | while read -r repo; do
        # issue #1: mirror so all branches, tags, and notes are cloned (issue #7: quote)
        git clone --mirror "$repo"
    done
done
