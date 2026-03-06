require_relative "../application_system_test_case"

class Authenticated::SidebarNavigationSystemTest < ApplicationSystemTestCase
  test "authenticated user on dashboard sees sidebar with two grouped sections and Dashboard highlighted" do
    sign_in_as users(:alice)
    visit dashboard_path

    within "[data-testid='sidebar']" do
      # Two section labels
      assert_selector "[data-testid='nav-section-label']", count: 2
      assert_text "Main"
      assert_text "Account"

      # Dashboard is active
      assert_selector "a.active", text: "Dashboard"

      # All expected nav items present
      assert_text "Dashboard"
      assert_text "Team"
    end
  end
end
