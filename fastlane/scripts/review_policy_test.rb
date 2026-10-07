require "minitest/autorun"
require_relative "review_policy"

class ReviewPolicyTest < Minitest::Test
  def version(state = "PREPARE_FOR_SUBMISSION", processing = "VALID", build = "7.1")
    { state: state, build_processing: processing, build_number: build }
  end

  def test_prepared_version_with_processed_build_can_be_submitted
    assert_equal :submit, ReviewPolicy.decision(version, [])
  end

  def test_existing_review_is_not_submitted_again
    assert_equal :already_submitted, ReviewPolicy.decision(version("IN_REVIEW"), [])
    assert_equal :already_submitted, ReviewPolicy.decision(version, [{ platform: "IOS", state: "WAITING_FOR_REVIEW" }])
  end

  def test_approved_version_is_not_submitted_again
    assert_equal :already_submitted, ReviewPolicy.decision(version("PENDING_DEVELOPER_RELEASE"), [])
  end

  def test_rejection_is_not_resubmitted_without_a_new_prepared_version
    assert_equal :blocked, ReviewPolicy.decision(version("REJECTED"), [])
    assert_equal :blocked, ReviewPolicy.decision(version, [{ platform: "IOS", state: "UNRESOLVED_ISSUES" }])
  end

  def test_missing_or_processing_build_blocks_submission
    assert_equal :blocked, ReviewPolicy.decision(version("PREPARE_FOR_SUBMISSION", "PROCESSING"), [])
    assert_equal :blocked, ReviewPolicy.decision(version("PREPARE_FOR_SUBMISSION", nil, nil), [])
  end

  def test_other_platform_does_not_block_ios
    assert_equal :submit, ReviewPolicy.decision(version, [{ platform: "MAC_OS", state: "IN_REVIEW" }])
  end
end
