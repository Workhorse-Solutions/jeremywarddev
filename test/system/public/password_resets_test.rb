require_relative "../application_system_test_case"

class Public::PasswordResetsSystemTest < ApplicationSystemTestCase
  test "submitting forgot password form shows neutral flash regardless of email" do
    visit new_password_reset_path

    fill_in "Email", with: "nonexistent@example.com"
    click_on I18n.t("public.password_resets.new.submit")

    assert_text I18n.t("public.password_resets.create.notice")
  end

  test "submitting forgot password form with existing email shows same neutral flash" do
    visit new_password_reset_path

    fill_in "Email", with: users(:alice).email
    click_on I18n.t("public.password_resets.new.submit")

    assert_text I18n.t("public.password_resets.create.notice")
  end

  test "valid reset token with matching passwords redirects to login with success flash" do
    user = users(:alice)
    token = user.password_reset_token

    visit edit_password_reset_path(token: token)

    fill_in "Password", with: "newsecurepassword"
    fill_in I18n.t("public.password_resets.edit.password_confirmation_label"), with: "newsecurepassword"
    click_on I18n.t("public.password_resets.edit.submit")

    assert_current_path login_path
    assert_text I18n.t("public.password_resets.update.notice")
  end

  test "mismatched passwords re-renders form with validation error" do
    user = users(:alice)
    token = user.password_reset_token

    visit edit_password_reset_path(token: token)

    fill_in "Password", with: "newsecurepassword"
    fill_in I18n.t("public.password_resets.edit.password_confirmation_label"), with: "different"
    click_on I18n.t("public.password_resets.edit.submit")

    assert_text "doesn't match"
  end
end
