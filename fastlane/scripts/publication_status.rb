# Read-only App Store Connect inventory. Never exports credentials or review contacts.
require "spaceship"
require "json"
require "net/http"
require "uri"
require "fileutils"
require "time"

module PublicationStatus
  module_function

  def get(path)
    uri = URI("https://api.appstoreconnect.apple.com#{path}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@token.text}"
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 20, read_timeout: 60) { |http| http.request(request) }
    raise "Apple GET #{uri.path} returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  end

  def inventory
    @token = Spaceship::ConnectAPI::Token.create(
      key_id: ENV.fetch("APP_STORE_CONNECT_KEY_ID"),
      issuer_id: ENV.fetch("APP_STORE_CONNECT_ISSUER_ID"),
      key: ENV.fetch("APP_STORE_CONNECT_KEY_CONTENT_BASE64"),
      is_key_content_base64: true
    )
    app_id = ENV.fetch("APP_STORE_CONNECT_APP_ID", "6800547603")
    expected_bundle = ENV.fetch("APP_IDENTIFIER", "app.vibehabits.ios")
    app = get("/v1/apps/#{app_id}").fetch("data")
    raise "App identity does not match #{expected_bundle}" unless app.dig("attributes", "bundleId") == expected_bundle
    versions = get("/v1/apps/#{app_id}/appStoreVersions?filter%5Bplatform%5D=IOS&limit=50").fetch("data")
    builds_data = get("/v1/apps/#{app_id}/builds?limit=10&include=preReleaseVersion")
    trains = builds_data.fetch("included", []).to_h { |item| [item["id"], item.dig("attributes", "version")] }
    builds = builds_data.fetch("data").map do |build|
      attrs = build.fetch("attributes")
      { id: build["id"], build_number: attrs["version"], version: trains[build.dig("relationships", "preReleaseVersion", "data", "id")], processing: attrs["processingState"], uploaded: attrs["uploadedDate"], expired: attrs["expired"] }
    end
    store_versions = versions.map do |version|
      attrs = version.fetch("attributes")
      localizations = get("/v1/appStoreVersions/#{version['id']}/appStoreVersionLocalizations?limit=200").fetch("data")
      locales = localizations.map do |locale|
        sets = get("/v1/appStoreVersionLocalizations/#{locale['id']}/appScreenshotSets?limit=200").fetch("data")
        screenshots = sets.map do |set|
          pictures = get("/v1/appScreenshotSets/#{set['id']}/appScreenshots?limit=200").fetch("data")
          { display: set.dig("attributes", "screenshotDisplayType"), count: pictures.length, delivery_states: pictures.map { |pic| pic.dig("attributes", "assetDeliveryState", "state") }.tally }
        end
        { locale: locale.dig("attributes", "locale"), description_present: !locale.dig("attributes", "description").to_s.empty?, support_url: locale.dig("attributes", "supportUrl"), screenshots: screenshots }
      end
      selected_build = get("/v1/appStoreVersions/#{version['id']}/build")["data"]
      { id: version["id"], version: attrs["versionString"], state: attrs["appVersionState"], release_type: attrs["releaseType"], build_number: selected_build&.dig("attributes", "version"), build_processing: selected_build&.dig("attributes", "processingState"), localizations: locales }
    end
    submissions = get("/v1/apps/#{app_id}/reviewSubmissions?limit=200").fetch("data").map do |item|
      { id: item["id"], state: item.dig("attributes", "state"), platform: item.dig("attributes", "platform") }
    end
    { assessed_at: Time.now.utc.iso8601, app: { id: app_id, name: app.dig("attributes", "name"), bundle_id: expected_bundle }, versions: store_versions, recent_builds: builds, review_submissions: submissions, manual_checks: ["Current App Privacy declarations", "Developer agreements and EU trader status", "App Review messages if the version was rejected"] }
  end

  def write_report
    require "time"
    report = inventory
    directory = ENV.fetch("PUBLICATION_REPORT_DIR", File.expand_path("../../artifacts/publication", __dir__))
    FileUtils.mkdir_p(directory)
    File.write(File.join(directory, "app-store-status.json"), JSON.pretty_generate(report) + "\n")
    puts "App Store status saved for #{report[:app][:name]} (#{report[:app][:bundle_id]})"
    report[:versions].each { |version| puts "#{version[:version]}: #{version[:state]}, build #{version[:build_number] || 'not selected'}" }
  end
end

PublicationStatus.write_report if $PROGRAM_NAME == __FILE__
