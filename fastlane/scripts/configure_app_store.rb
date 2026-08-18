require "spaceship"

token = Spaceship::ConnectAPI::Token.create(
  key_id: ENV.fetch("APP_STORE_CONNECT_KEY_ID"),
  issuer_id: ENV.fetch("APP_STORE_CONNECT_ISSUER_ID"),
  filepath: ENV.fetch("APP_STORE_CONNECT_KEY_PATH")
)
Spaceship::ConnectAPI.token = token

bundle_id = ENV.fetch("APP_IDENTIFIER", "app.vibehabits.ios")
version_string = ENV.fetch("APP_STORE_VERSION", "1.1.0")
app = Spaceship::ConnectAPI::App.find(bundle_id)
raise "App #{bundle_id} was not found" unless app

app.update(attributes: {
  content_rights_declaration: Spaceship::ConnectAPI::App::ContentRightsDeclaration::DOES_NOT_USE_THIRD_PARTY_CONTENT
})

version = app.get_app_store_versions(filter: { platform: "IOS" }).find do |candidate|
  candidate.app_version_state == Spaceship::ConnectAPI::AppStoreVersion::AppVersionState::PREPARE_FOR_SUBMISSION
end
raise "No editable iOS version was found" unless version

version.update(attributes: {
  version_string: version_string,
  copyright: "2026 Raphael Canguçu",
  release_type: Spaceship::ConnectAPI::AppStoreVersion::ReleaseType::MANUAL
})

app_info = app.fetch_edit_app_info
raise "No editable app information record was found" unless app_info

app_info.update_categories(category_id_map: {
  primary_category_id: "PRODUCTIVITY",
  secondary_category_id: "HEALTH_AND_FITNESS"
})

age_rating = app_info.fetch_age_rating_declaration
age_rating.update(attributes: {
  advertising: false,
  age_assurance: false,
  alcohol_tobacco_or_drug_use_or_references: "NONE",
  contests: "NONE",
  gambling: false,
  gambling_simulated: "NONE",
  guns_or_other_weapons: "NONE",
  health_or_wellness_topics: true,
  horror_or_fear_themes: "NONE",
  loot_box: false,
  mature_or_suggestive_themes: "NONE",
  medical_or_treatment_information: "NONE",
  messaging_and_chat: false,
  parental_controls: false,
  profanity_or_crude_humor: "NONE",
  sexual_content_graphic_and_nudity: "NONE",
  sexual_content_or_nudity: "NONE",
  unrestricted_web_access: false,
  user_generated_content: false,
  violence_cartoon_or_fantasy: "NONE",
  violence_realistic_prolonged_graphic_or_sadistic: "NONE",
  violence_realistic: "NONE",
  age_rating_override_v2: "NONE",
  korea_age_rating_override: "NONE"
})

puts "Configured #{app.name} #{version_string} for manual release"
