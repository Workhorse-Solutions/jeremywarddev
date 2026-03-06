require_relative "../../application_system_test_case"

class Authenticated::Settings::AccountsSystemTest < ApplicationSystemTestCase
  setup do
    @alice = users(:alice)
    sign_in_as @alice
  end

  test "name field is pre-filled with the current account name" do
    visit edit_settings_account_path
    assert_field I18n.t("authenticated.settings.accounts.edit.name_label"), with: accounts(:acme).name
  end

  test "submitting with blank name shows inline validation error" do
    visit edit_settings_account_path
    fill_in I18n.t("authenticated.settings.accounts.edit.name_label"), with: ""
    click_button I18n.t("authenticated.settings.accounts.edit.submit")
    assert_text "can't be blank"
  end

  test "successful account update redirects with flash" do
    visit edit_settings_account_path
    fill_in I18n.t("authenticated.settings.accounts.edit.name_label"), with: "Updated Corp"
    click_button I18n.t("authenticated.settings.accounts.edit.submit")
    assert_current_path edit_settings_account_path
    assert_text I18n.t("authenticated.settings.accounts.update.notice")
  end

  test "billing section is visible with no form inputs" do
    visit edit_settings_account_path
    assert_selector "[data-testid='billing-section']"
    within "[data-testid='billing-section']" do
      assert_no_selector "input"
      assert_no_selector "button"
    end
  end
end
