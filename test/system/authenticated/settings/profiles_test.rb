require_relative "../../application_system_test_case"

class Authenticated::Settings::ProfilesSystemTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    sign_in_as @alice
  end

  # UDD-003 [UI story] tests
  test "Personal Details fields are pre-filled with current user values" do
    visit edit_settings_profile_path
    assert_field I18n.t("authenticated.settings.profiles.edit.personal_details.first_name_label"),
      with: @alice.first_name
    assert_field I18n.t("authenticated.settings.profiles.edit.personal_details.last_name_label"),
      with: @alice.last_name
  end

  test "successful personal details save redirects with flash" do
    visit edit_settings_profile_path
    fill_in I18n.t("authenticated.settings.profiles.edit.personal_details.first_name_label"), with: "Alicia"
    fill_in I18n.t("authenticated.settings.profiles.edit.personal_details.last_name_label"), with: "Updated"
    click_button I18n.t("authenticated.settings.profiles.edit.personal_details.submit")
    assert_current_path edit_settings_profile_path
    assert_text I18n.t("authenticated.settings.profiles.update.notice")
  end

  # UDD-004 [UI story] tests
  test "Security section contains three password fields" do
    visit edit_settings_profile_path
    assert_field I18n.t("authenticated.settings.profiles.edit.security.current_password_label")
    assert_field I18n.t("authenticated.settings.profiles.edit.security.new_password_label")
    assert_field I18n.t("authenticated.settings.profiles.edit.security.password_confirmation_label")
  end

  test "incorrect current password shows inline error" do
    visit edit_settings_profile_path
    fill_in I18n.t("authenticated.settings.profiles.edit.security.current_password_label"), with: "wrongpassword"
    fill_in I18n.t("authenticated.settings.profiles.edit.security.new_password_label"), with: "newpassword1"
    fill_in I18n.t("authenticated.settings.profiles.edit.security.password_confirmation_label"), with: "newpassword1"
    click_button I18n.t("authenticated.settings.profiles.edit.security.submit")
    assert_text "Current password is incorrect"
  end

  # UDD-005 [UI story] test
  test "Security section displays current email and Change email link" do
    visit edit_settings_profile_path
    within "[data-testid='email-row']" do
      assert_text @alice.email
      assert_link I18n.t("authenticated.settings.profiles.edit.security.change_email"),
        href: edit_email_settings_path
    end
  end

  test "successful password change redirects with flash and user remains signed in" do
    visit edit_settings_profile_path
    fill_in I18n.t("authenticated.settings.profiles.edit.security.current_password_label"), with: "password"
    fill_in I18n.t("authenticated.settings.profiles.edit.security.new_password_label"), with: "newpassword1"
    fill_in I18n.t("authenticated.settings.profiles.edit.security.password_confirmation_label"), with: "newpassword1"
    click_button I18n.t("authenticated.settings.profiles.edit.security.submit")
    assert_current_path edit_settings_profile_path
    assert_text I18n.t("authenticated.settings.profiles.update_password.notice")
    # User remains signed in — authenticated page is accessible
    visit edit_settings_profile_path
    assert_current_path edit_settings_profile_path
  end
end
