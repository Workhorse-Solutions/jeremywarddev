require_relative "../application_system_test_case"

class Authenticated::EmailChangesSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
    sign_in_as @user
  end

  test "submitting email change form with correct password shows success flash" do
    visit edit_settings_profile_path
    click_link I18n.t("authenticated.settings.profiles.edit.security.change_email")

    fill_in I18n.t("authenticated.email_changes.edit.new_email_label"), with: "newalice@example.com"
    fill_in I18n.t("authenticated.email_changes.edit.current_password_label"), with: "password"
    click_button I18n.t("authenticated.email_changes.edit.submit")

    assert_text I18n.t("authenticated.email_changes.update.notice")
    # Current email is unchanged
    assert_equal "alice@acme.com", @user.reload.email
  end

  test "submitting email change form with wrong password shows error" do
    visit edit_settings_profile_path
    click_link I18n.t("authenticated.settings.profiles.edit.security.change_email")

    fill_in I18n.t("authenticated.email_changes.edit.new_email_label"), with: "newalice@example.com"
    fill_in I18n.t("authenticated.email_changes.edit.current_password_label"), with: "wrongpassword"
    click_button I18n.t("authenticated.email_changes.edit.submit")

    assert_text "invalid"
  end

  test "submitting email change form with duplicate email shows error" do
    User.create!(email: "taken@example.com", password: "password12", password_confirmation: "password12")

    visit edit_settings_profile_path
    click_link I18n.t("authenticated.settings.profiles.edit.security.change_email")

    fill_in I18n.t("authenticated.email_changes.edit.new_email_label"), with: "taken@example.com"
    fill_in I18n.t("authenticated.email_changes.edit.current_password_label"), with: "password"
    click_button I18n.t("authenticated.email_changes.edit.submit")

    assert_text "already taken"
  end
end
