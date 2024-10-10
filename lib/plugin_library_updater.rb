# Update all repositories in a GitHub organisation, assuming each one has been
# mirrored from wordpress.org. Optionally print a summary of the updates
# that have been performed or have errored.
class AbstractPluginLibraryUpdater
  def initialize
    @failed_updates = {}
    @updated_plugins = {}
    @skipped_plugins = []
  end

  def update
    raise NotImplementedError, "This method must be overridden in a subclass"
  end

  def print_summary
    print_skipped_plugin_summary
    print_updated_plugin_summary
    print_failed_plugin_summary
  end

  private

  def print_skipped_plugin_summary
    return if @skipped_plugins.empty?

    hrule
    puts "==> Skipped the following #{@skipped_plugins.size} plugin(s):"
    puts
    puts @skipped_plugins
  end

  def print_updated_plugin_summary
    raise NotImplementedError, "This method must be overridden in a subclass"
  end

  def print_failed_plugin_summary
    return if @failed_updates.empty?

    hrule
    puts "==> Failed to update the following #{@failed_updates.size} plugin(s):"
    @failed_updates.each do |name, error_message|
      puts
      puts "*** #{name} failed to update with message:"
      puts error_message
    end
  end

  def hrule
    puts
    puts "-----------------------------------------------------------------------"
  end
end
