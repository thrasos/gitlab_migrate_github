#!/bin/bash
set -uo pipefail

GITLAB_TOKEN="YOUR_GITLAB_TOKEN"
GITHUB_TOKEN="YOUR_GITHUB_TOKEN"
GITLAB_DOMAIN="https://gitlab.com"
GITHUB_USER="your_github_username"

# issue #4: let gh pick up the token instead of leaving GITHUB_TOKEN unused
export GH_TOKEN="$GITHUB_TOKEN"

# Get the total number of pages (issue #6: validate before looping)
TOTAL_PAGES=$(curl -sf --head --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100" | grep -i "x-total-pages" | tr -d '\r' | awk '{print $2}')

if ! [[ "$TOTAL_PAGES" =~ ^[0-9]+$ ]]; then
    echo "Failed to read X-Total-Pages (bad token, network error, or wrong domain?)" >&2
    exit 1
fi

# Loop through each page and migrate the repos
for ((i=1; i<=TOTAL_PAGES; i++)); do
    echo "Fetching page $i"
    # issue #3: use the namespaced path so projects with the same name in
    # different groups don't collide; flatten "/" to "-" for the GitHub name.
    curl -sf --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100&page=$i" \
        | jq -r '.[] | [.ssh_url_to_repo, .path_with_namespace] | @tsv' \
        | while IFS=$'\t' read -r repo path_with_namespace; do
        repo_name="${path_with_namespace//\//-}"
        mirror_dir="$repo_name.git"

        # issue #1: mirror clone so all branches, tags, and notes come across
        echo "Cloning $path_with_namespace from GitLab..."
        if ! git clone --mirror "$repo" "$mirror_dir"; then
            echo "Clone failed for $path_with_namespace, skipping" >&2
            continue
        fi

        # Create a new repository on GitHub (issue #5: --confirm is deprecated)
        echo "Creating $repo_name on GitHub..."
        gh repo create "$GITHUB_USER/$repo_name" --private

        # issue #2: guard the cd so a failure never leaves us pushing the wrong repo
        cd "$mirror_dir" || { echo "Cannot enter $mirror_dir, skipping" >&2; continue; }

        # Change the origin URL to the GitHub repo URL
        git remote set-url origin "git@github.com:$GITHUB_USER/$repo_name.git"

        # issue #1: push everything (all branches and tags), not just master
        echo "Pushing to GitHub..."
        git push --mirror

        # Get out of the repository
        cd ..

        # Optionally, remove the local copy if you no longer need it
        # rm -rf "$mirror_dir"
    done
done
