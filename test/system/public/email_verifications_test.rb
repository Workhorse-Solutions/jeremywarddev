require_relative "../application_system_test_case"

class Public::EmailVerificationsSystemTest < ApplicationSystemTestCase
  test "valid verification link redirects to dashboard with success flash" do
    user = users(:alice)
    token = user.generate_token_for(:email_verification)

    visit verify_email_path(token: token)

    assert_current_path dashboard_path
    assert_text I18n.t("public.email_verifications.show.success")
  end

  test "invalid verification link redirects to resend page with error flash" do
    visit verify_email_path(token: "invalid-token")

    assert_current_path verify_email_path
    assert_text I18n.t("public.email_verifications.show.invalid_token")
  end

  test "expired verification link redirects to resend page with error flash" do
    user = users(:alice)
    token = user.generate_token_for(:email_verification)

    # Verify first, invalidating the token (fingerprinted on email_verified_at)
    user.mark_email_verified!

    visit verify_email_path(token: token)

    assert_current_path verify_email_path
    assert_text I18n.t("public.email_verifications.show.invalid_token")
  end

  test "submitting resend form shows neutral flash regardless of email entered" do
    visit verify_email_path

    fill_in "Email", with: "anyone@example.com"
    click_button I18n.t("public.email_verifications.resend.submit")

    assert_text I18n.t("public.email_verifications.resend.notice")
  end
end
