module ReviewPolicy
  ACTIVE = %w[WAITING_FOR_REVIEW IN_REVIEW CANCELING COMPLETING].freeze
  ADVANCED_VERSION = %w[WAITING_FOR_REVIEW IN_REVIEW WAITING_FOR_EXPORT_COMPLIANCE PENDING_APPLE_RELEASE PENDING_DEVELOPER_RELEASE PROCESSING_FOR_APP_STORE READY_FOR_DISTRIBUTION READY_FOR_SALE].freeze
  module_function

  def decision(version, submissions)
    return :already_submitted if ADVANCED_VERSION.include?(version.fetch(:state))
    ios = submissions.select { |item| item[:platform] == "IOS" }
    return :blocked if ios.any? { |item| item[:state] == "UNRESOLVED_ISSUES" }
    return :already_submitted if ios.any? { |item| ACTIVE.include?(item[:state]) }
    return :blocked unless version[:state] == "PREPARE_FOR_SUBMISSION"
    return :blocked unless version[:build_processing] == "VALID" && !version[:build_number].to_s.empty?
    :submit
  end
end
