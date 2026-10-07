# Shared App Store Connect token loader for standalone Fastlane scripts.
# Local keys must stay outside the repository with owner-only permissions.
require "spaceship"

module ConnectApiToken
  module_function

  ROOT = File.expand_path("../..", __dir__)

  def create
    key_id = ENV.fetch("APP_STORE_CONNECT_KEY_ID")
    issuer_id = ENV.fetch("APP_STORE_CONNECT_ISSUER_ID")
    key_path = ENV["APP_STORE_CONNECT_KEY_PATH"]
    unless key_path.to_s.empty?
      requested = File.expand_path(key_path)
      raise "Apple API key is unavailable: #{requested}" unless File.file?(requested)
      path = File.realpath(requested)
      raise "Keep the Apple API key outside the project" if path.start_with?(ROOT + "/")
      raise "Apple API key must be readable only by its owner (chmod 600)" unless (File.stat(path).mode & 0077).zero?
      return Spaceship::ConnectAPI::Token.create(
        key_id: key_id,
        issuer_id: issuer_id,
        filepath: path
      )
    end

    Spaceship::ConnectAPI::Token.create(
      key_id: key_id,
      issuer_id: issuer_id,
      key: ENV.fetch("APP_STORE_CONNECT_KEY_CONTENT_BASE64"),
      is_key_content_base64: true
    )
  end
end
