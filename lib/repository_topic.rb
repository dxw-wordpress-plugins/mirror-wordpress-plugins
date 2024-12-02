# A repository topic is a single piece of metadata displayed on the repo page.
# This class takes strings, which will usually be from the WordPress API into
# a repository topic which can be added or removed from a repository.
#
# Example error and `reason_text` JSON values include that might be used as
# topics include:
#
#   * closed
#   * Plugin not found.
#   * Guideline Violation
#   * Security Issue
#
# These are not documented and not in a consistent format. So, we remove
# any punctuation and replace spacing with dashes before storing the string.
class RepositoryTopic
  @@separator = "-".freeze
  @@skip_mirror_topic = "skip-mirror".freeze

  attr_reader :value, :repo

  def initialize(text, repo, prefix = "")
    clean_text = text.to_s.gsub(/[^a-z0-9\-\s]/i, "").downcase.gsub(/\s+/, "-")
    @value = prefix.nil? || prefix.empty? ? clean_text : "#{prefix}#{@@separator}#{clean_text}"
    @repo = repo
  end

  def self.skip_mirror_topic
    @@skip_mirror_topic
  end

  def add_to_repo
    puts "==> Adding topic #{@value} to repo..."
    edit_repo("add")
  end

  def remove_from_repo
    puts "==> Removing topic #{@value} from repo..."
    edit_repo("remove")
  end

  private

  def edit_repo(action)
    if dry_run? && !force_annotation?
      puts "... -- Dry run mode, no repo edits taking place --"
    else
      `gh repo edit #{@repo} --#{action}-topic #{@value}`
    end
  end
end
