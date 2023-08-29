#!/bin/bash

TOKEN="YOUR_TOKEN"
GITLAB_DOMAIN="https://gitlab.com"

# Get the number of pages
TOTAL_PAGES=$(curl -s --head --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100" | grep -i "x-total-pages" | tr -d '\r' | awk '{print $2}')

# Loop through each page and clone the repos
for ((i=1; i<=$TOTAL_PAGES; i++)); do
    echo "Fetching page $i"
    curl --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100&page=$i" | jq -r '.[].ssh_url_to_repo' | while read repo; do
        git clone $repo
    done
done
