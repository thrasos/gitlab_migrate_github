# gitlab migrate github*
Automate the cloning of your GitLab repositories and optionally push them to GitHub with these Bash scripts.


# GitLab to GitHub Repository Migration Script
So you have gazillions of repositories on Gitlab( and you don't want to use the glab func below), and for some reason, you need to download them all and perhaps push them to GitHub (I don't know why, but people do crazy things); you are at the right place.
This repository contains two Bash scripts that automate the process of cloning your repositories from GitLab and then pushing them to GitHub.

## Prerequisites

- GitLab Personal Access Token: used to list your projects via the GitLab API.
- SSH keys: **required**. Both scripts clone over SSH (`ssh_url_to_repo`) and the migration script pushes over SSH (`git@github.com:...`), so you need a working SSH key registered on GitLab, and on GitHub too if you push. The GitLab token is only used for the API listing, not for the clone itself.
- GitHub Personal Access Token: only needed for `clone_all_gitlab_pust_to_Github.sh`, to create new repositories on GitHub.
- `curl` and `jq` must be installed. `gh` is only required for `clone_all_gitlab_pust_to_Github.sh`.
  
## Scripts

### `clone_all_gitlab.sh`

This script clones all your repositories from your GitLab account **locally**. It does not touch GitHub — use `clone_all_gitlab_pust_to_Github.sh` for that. Clones are made with `git clone --mirror`, so you get every branch, tag and note as a bare repository (no working tree).
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

This script clones all repositories from your GitLab account (even if they are more than 100 due to pagination) and pushes them to your GitHub account. It creates a corresponding **private** repository on GitHub for each one and mirror-pushes it, so all branches and tags are migrated. Repositories are named after their full GitLab path (e.g. `group/app` becomes `group-app`) to avoid collisions between groups.

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

##glab
upload your public certificate to your gitlab profile then run
```
eval "$(ssh-agent -s)"  (run the agent)
ssh-add ~/.ssh/id_rsa  (or wherever the ssh is located)
glab repo clone -g project_id -p --paginate  
```
