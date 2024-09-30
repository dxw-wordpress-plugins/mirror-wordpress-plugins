# Generic error class, can be caught but should not be raised.
class PluginUpdateError < StandardError
end

# Could not retrieve information about a given plugin.
class WordPressPluginApiError < PluginUpdateError
end

# Could retrieve API information but it included an error.
class WordPressPluginJSONContainsError < PluginUpdateError
  attr_reader :reason
  def initialize(msg = "Error from wordpress.org", reason = "")
    @reason = reason
    super(msg)
  end
end

# Could not download a .zip file for a given plugin.
class WordPressPluginDownloadError < PluginUpdateError
end

# Could not unzip the .zip file for a given plugin.
class WordPressPluginUnzipError < PluginUpdateError
end

# Could not perform Git action on repo. Only useful for interacting with remotes.
class GitError < PluginUpdateError
end

# Could not find a latest version tag for the plugin
class MissingVersionError < PluginUpdateError
end

# A plugin file did not have the same checksum as the equivalent file on wordpress.org.
class WordPressPluginChecksumMismatchError < PluginUpdateError
end
