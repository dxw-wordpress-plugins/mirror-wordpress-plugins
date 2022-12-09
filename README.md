# Mirror GitLab plugins to GitHub

This repo includes a GitHub action that runs on a schedule, mirroring all the 3rd-party plugins we hold on GitLab to private repos on GitHub twice a day.

Having both the plugins and application repos hosted on GitHub will make it much easier for us to report accurately on what versions of plugins we're running across our WordPress estate.

The mirrored repos hosted on GitHub are intended to be read-only, and we will still be deploying from the GitLab-hosted versions.

## Potential causes of workflow failure

Occasionally, the action will fail. There are a couple of commons causes for this:

1. The code assumes that the default branch for GitLab repos will match the value of the `DEFAULT_BRANCH_NAME` secret (currently set to `master`). If this is not the case (or if the `DEFAULT_BRANCH_NAME` branch does exist, but is not the default branch), the workflow may fail. Potential fix: make the expected branch the default for the GitLab repo in question.

1. The connection to GitLab times out, or returns some other unexpected response. This is normally a temporary glitch, and will resolve itself on the next workflow run.

## Testing locally

You can test the action locally using [act](https://github.com/nektos/act).

Install act:
```
brew install act
```

Then copy the `.env.example` file to `.env`, and populate it with the appropriate values (you can use the values from the service accounts in 1password if needed).

Then run the action with:

```
act -j mirror-gitlab-plugins --secret-file .env
```

NOTE: this will actually start the mirroring process off for real, and there are over 700 plugins to be mirrored! So you may want to tweak lines 58 & 60 of the `mirror-plugins` script to reduce that number, e.g.:

```
projects = Gitlab.group_projects(ENV['GITLAB_WORDPRESS_PLUGINS_GROUP_ID'], per_page: 10)

projects.each do |project|
```

If the loop starts with `projects.auto_paginate do |project|`, it will always run through the entire set.
