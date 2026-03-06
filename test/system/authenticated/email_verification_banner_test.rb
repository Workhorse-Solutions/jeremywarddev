require_relative "../application_system_test_case"

class Authenticated::EmailVerificationBannerSystemTest < ApplicationSystemTestCase
  test "unverified user sees verification banner with resend button" do
    sign_in_as users(:alice)

    assert_selector "[data-testid='email-verification-banner']"
    assert_text I18n.t("authenticated.email_verification_banner.resend")
  end

  test "clicking resend sends verification email and redirects to dashboard" do
    sign_in_as users(:alice)

    click_button I18n.t("authenticated.email_verification_banner.resend")

    assert_text I18n.t("authenticated.email_verifications.resend.notice")
    assert_current_path dashboard_path
  end

  test "verified user does not see verification banner" do
    user = users(:alice)
    user.mark_email_verified!

    sign_in_as user

    assert_no_selector "[data-testid='email-verification-banner']"
  end
end
