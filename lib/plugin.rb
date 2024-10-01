# A Plugin is a representation of a GitHub repository that mirrors a
# plugin from wordpress.org. Plugins are responsible for updating
# their related repositories.
class AbstractPlugin
  attr_reader :slug, :repo, :github_url, :full_path_to_clone, :latest_plugin_version_on_github

  def initialize(name, github_url)
    @slug = name
    @repo = "#{ENV.fetch("GH_ORG_NAME")}/#{@slug}"
    @github_url = github_url
    @github_https_url = "#{@github_url}.git"
    @full_path_to_clone = File.join(Dir.pwd, @slug)
    @tmp_plugin_dir = File.join(Dir.pwd, "tmp", @slug)
  end

  def cleanup
    puts "==> Cleaning up downloaded files..."
    if defined?(dry_run) && dry_run?
      puts "... -- Dry run mode, leaving downloaded files so they can be manually verified --"
    else
      `rm -rf #{@zip_file}`
      `rm -rf #{@full_path_to_clone}`
      `rm -rf #{@tmp_files_for_plugin}`
    end
  end

  private

  def clean_local_files
    `git -C #{@full_path_to_clone} clean -fd`
  end

  def construct_github_https_url
    credentials = ENV.fetch("GH_ACCOUNT_USERNAME") + ":" + ENV.fetch("GH_ACCOUNT_TOKEN") + "@"
    url = "https://github.com/" + ENV.fetch("GH_ORG_NAME") + "/" + @slug + ".git"
    url.insert(8, credentials)
  end

  def fetch_latest_plugin_version_on_github
    puts("==> Querying GitHub for latest version ...")
    @latest_plugin_version_on_github = `gh api repos/#{ENV.fetch("GH_ORG_NAME")}/#{@slug}/git/refs/tags --jq '.[].ref' | cut -d '/' -f 3 | grep -Eo "[0-9\.]+" | sort -V | tail -n 1`
    # Assume the repo is empty and/or does not have any tags.
    return "" unless $CHILD_STATUS.success? && @latest_plugin_version_on_github.strip != "."
    "v#{@latest_plugin_version_on_github}"
  end
end
