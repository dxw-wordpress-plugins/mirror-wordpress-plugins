# Get information about organisation plugins from GitHub and transform into an
# array of PluginUpdater objects.
class AbstractPluginCollection
  @@max_repos_in_library = 99_999 # Effectively unlimited.

  def initialize
    @plugins = []
  end

  def build
    raise NotImplementedError, "This method must be overridden in a subclass"
  end

  private

  def plugin_library_repos
    puts "==> Fetching all GitHub plugin repositories in the library..."
    `gh repo list #{ENV.fetch("GH_ORG_NAME")} --limit=#{@@max_repos_in_library} --json=name,url,repositoryTopics --no-archived`
  end
end
