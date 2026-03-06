require_relative "../../application_system_test_case"

class Authenticated::Settings::UserDropdownSystemTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:alice)
  end

  test "dropdown contains Account and Settings links and not Dashboard or Pricing" do
    visit dashboard_path

    within "[data-testid='user-dropdown-menu']" do
      assert_link I18n.t("authenticated.layout.nav.account"),
        href: edit_settings_account_path
      assert_link I18n.t("authenticated.layout.nav.settings"),
        href: edit_settings_profile_path
      assert_no_link I18n.t("authenticated.layout.nav.dashboard")
      assert_no_link I18n.t("authenticated.layout.nav.pricing")
    end
  end
end
