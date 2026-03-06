require_relative "../application_system_test_case"

class Public::EmailChangesSystemTest < ApplicationSystemTestCase
  test "valid email-change confirmation link shows success flash and updates email" do
    user = users(:alice)
    user.update!(unconfirmed_email: "newalice@example.com")
    token = user.generate_token_for(:email_change)

    visit confirm_email_change_path(token: token)

    assert_text I18n.t("public.email_changes.show.success")
    assert_equal "newalice@example.com", user.reload.email
  end

  test "expired email-change link redirects with error flash" do
    user = users(:alice)
    user.update!(unconfirmed_email: "newalice@example.com")
    token = user.generate_token_for(:email_change)

    # Invalidate by clearing unconfirmed_email (token is fingerprinted on it)
    user.update!(unconfirmed_email: nil)

    visit confirm_email_change_path(token: token)

    assert_text I18n.t("public.email_changes.show.invalid_token")
  end
end
