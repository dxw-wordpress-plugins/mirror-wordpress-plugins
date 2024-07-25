# Mirror GitLab plugins to GitHub

This repo includes a GitHub action that runs on a schedule, mirroring all the 3rd-party plugins we hold on GitLab to private repos on GitHub twice a day.

Having both the plugins and application repos hosted on GitHub will make it much easier for us to report accurately on what versions of plugins we're running across our WordPress estate.

All Dalmatian-hosted sites have access to the plugins in the `dxw-wordpress-plugins` org, and should be configured in their `whippet.json` file to use those, rather than their GitLab equivalents. Projects on GovPress v1 architecture still use the GitLab-hosted versions.

## Potential causes of workflow failure

Occasionally, the action will fail. When it does so, it will alert the GovPress Team channel (set by the `SLACK_CHANNEL_ID` secret) via the GovPress Tools Slackbot (set via `SLACK_BOT_TOKEN`).

There are a couple of commons causes for failures:

1. The code assumes that the default branch for GitLab repos will match the value of the `DEFAULT_BRANCH_NAME` secret (currently set to `master`). If this is not the case (or if the `DEFAULT_BRANCH_NAME` branch does exist, but is not the default branch), the workflow may fail. Potential fix: make the expected branch the default for the GitLab repo in question.

1. The connection to GitLab times out, or returns some other unexpected response. This is normally a temporary glitch, and will resolve itself on the next workflow run.

## Testing locally

You can test the action locally using [act](https://github.com/nektos/act).

Install act:
```
brew install act
```

Then copy the `.env.example` file to `.env`, and populate it with the appropriate values (you can use the values from the service accounts in 1password if needed). In particular, set `DRY_RUN_MIRROR=true`, so that no real changes are made.

Then run the action with:

```
act -j mirror-gitlab-plugins --secret-file .env
```

If you're using a machine with an ARM-based processor, you may need to do:

```
act -j mirror-gitlab-plugins --secret-file .env --container-architecture linux/amd64
```

NOTE: if you don't set `DRY_RUN_MIRROR=true`, this will actually start the mirroring process off for real, and there are over 700 plugins to be mirrored! If you mean to do this (e.g. to test against a small batch of real data) you may want to tweak this line of the `mirror-wordpress-plugins` script to reduce that number.

That is change:

```ruby
@@max_repos_in_library = 99_999 # Effectively unlimited.
```

to something like:

```ruby
@@max_repos_in_library = 10 # Effectively unlimited.
```
