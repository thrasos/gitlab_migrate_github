# gitlab migrate github*
Automate the cloning of your GitLab repositories and optionally push them to GitHub with these Bash scripts.


# GitLab to GitHub Repository Migration Script
So you have gazillions of repositories on Gitlab, and for some reason, you need to download them all and perhaps push them to GitHub (I don't know why, but people do crazy things); you are at the right place.

This repository contains two Bash scripts that automate the process of cloning your repositories from GitLab and then pushing them to GitHub.

## Prerequisites

- GitLab Personal Access Token: Required for cloning repositories from your GitLab account.
- GitHub Personal Access Token: Required for creating new repositories in your GitHub account.
- `curl`, `jq`, and `gh` must be installed.
  
## Scripts

### `clone_all_gitlab.sh`

This script clones all your repositories from your GitLab account and pushes them to your GitHub account.
The GitLab API uses pagination, and by default, it returns 20 items per page. Even if you set per_page to 100, you'll only get the first 100 projects. 
so what we do is :
- First, determine the number of pages of projects you have. This can be found in the X-Total-Pages header of the GitLab API response.
- Loop over each page and retrieve the projects.

#### How to Use `clone_all_gitlab.sh`

1. Make the script executable:
    ```bash
    chmod +x clone_all_gitlab.sh
    ```

2. Open `clone_all_gitlab.sh` and replace `TOKEN` with your actual GitLab token.

3. Run the script:
    ```bash
    ./clone_all_gitlab.sh
    ```

### `clone_all_gitlab_pust_to_Github.sh`

This script clones all repositories from your GitLab account (even if they are more than 100 due to pagination) and pushes them to your GitHub account.

#### How to Use `clone_all_gitlab_pust_to_Github.sh`

1. Make the script executable:
    ```bash
    chmod +x clone_all_gitlab_pust_to_Github.sh
    ```

2. Open `clone_all_gitlab_pust_to_Github.sh` and replace `YOUR_GITLAB_TOKEN`, `YOUR_GITHUB_TOKEN`, and `your_github_username` with your actual tokens and GitHub username.

3. Run the script:
    ```bash
    ./clone_all_gitlab_pust_to_Github.sh
    ```

**Caution**: These scripts will create a lot of repositories in your GitHub account based on your GitLab account. Make sure you want to proceed before running the scripts.

## Features

- Fetches repositories from GitLab.
- Creates corresponding private repositories on GitHub.
- Pushes the code from your GitLab repositories to your GitHub repositories.

