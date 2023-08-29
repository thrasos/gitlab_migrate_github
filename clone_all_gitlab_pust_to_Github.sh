#!/bin/bash

GITLAB_TOKEN="YOUR_GITLAB_TOKEN"
GITHUB_TOKEN="YOUR_GITHUB_TOKEN"
GITLAB_DOMAIN="https://gitlab.com"
GITHUB_USER="your_github_username"

# Get the total number of pages
TOTAL_PAGES=$(curl -s --head --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100" | grep -i "x-total-pages" | tr -d '\r' | awk '{print $2}')

# Loop through each page and clone the repos
for ((i=1; i<=$TOTAL_PAGES; i++)); do
    echo "Fetching page $i"
    curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_DOMAIN/api/v4/projects?membership=true&per_page=100&page=$i" | jq -r '.[].ssh_url_to_repo' | while read repo; do
        repo_name=$(basename $repo .git)
        
        # Clone from GitLab
        echo "Cloning $repo_name from GitLab..."
        git clone $repo

        # Create a new repository on GitHub
        echo "Creating $repo_name on GitHub..."
        gh repo create $GITHUB_USER/$repo_name --private --confirm

        # Change the origin URL to GitHub repo URL
        cd $repo_name
        git remote set-url origin git@github.com:$GITHUB_USER/$repo_name.git

        # Push to GitHub
        echo "Pushing to GitHub..."
        git push -u origin master

        # Get out of the repository
        cd ..

        # Optionally, remove the local copy if you no longer need it
        # rm -rf $repo_name
    done
done
