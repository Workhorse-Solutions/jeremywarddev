require "test_helper"

class SidebarNavigationTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
  end

  test "sidebar renders two grouped sections" do
    sign_in_as @alice
    get dashboard_path
    assert_response :ok

    assert_select "[data-testid='sidebar']" do
      assert_select "[data-testid='nav-section-label']", count: 2
      assert_select ".menu-title", text: "Main"
      assert_select ".menu-title", text: "Account"
    end
  end

  test "sidebar contains Dashboard in Main section" do
    sign_in_as @alice
    get dashboard_path

    assert_select "[data-testid='sidebar']" do
      assert_select "a[href='#{dashboard_path}']", text: "Dashboard"
    end
  end

  test "sidebar contains Team in Account section" do
    sign_in_as @alice
    get dashboard_path

    assert_select "[data-testid='sidebar']" do
      assert_select "a[href='#{team_path}']", text: "Team"
    end
  end

  test "active nav item is highlighted on dashboard" do
    sign_in_as @alice
    get dashboard_path

    assert_select "[data-testid='sidebar'] a.active[href='#{dashboard_path}']"
  end

  test "active nav item is highlighted on team page" do
    sign_in_as @alice
    get team_path

    assert_select "[data-testid='sidebar'] a.active[href='#{team_path}']"
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
