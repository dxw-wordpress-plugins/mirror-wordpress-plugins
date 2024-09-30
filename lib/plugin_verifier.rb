require_relative "./error_mixin"

require "digest"

#
# This class verifies that the files in a plugin mirrored from wordpress.org are
# consistent with the checksums that WordPress makes available via a JSON API.
#
class PluginVerifier
  attr_reader :slug, :full_path_to_clone, :checksum_url

  @@checksum_api = "https://downloads.wordpress.org/plugin-checksums/".freeze

  def initialize(slug, version, path)
    @slug = slug
    @full_path_to_clone = path
    @checksum_url = [@@checksum_api, @slug, version + ".json"].join("/")
  end

  def verify_checksums
    puts("==> Verifying checksums...")
    checksums = fetch_checksums
    return if checksums.nil?

    checksums.each do |file, hashes|
      checksum = hashes["sha256"]
      calculated_checksum = calculate_checksum(File.join(@full_path_to_clone, file))
      if calculated_checksum != checksum
        raise WordPressPluginChecksumMismatchError, "#{file} checksum mismatch. Expected: #{checksum}, Calculated: #{calculated_checksum}"
      end
    end
  end

  private

  def calculate_checksum(path)
    Digest::SHA256.file(path).hexdigest
  end

  def fetch_checksums
    puts("==> Querying api.wordpress.org for checksums ...")
    api_info = `curl -s #{@checksum_url}`
    raise WordPressPluginApiError, "No WordPress API info available for #{@slug}" if api_info.nil?

    begin
      checksum_info = JSON.parse(api_info)
    rescue JSON::ParserError => e
      raise WordPressPluginApiError, e.message
    end
    checksum_info["files"]
  end
end
