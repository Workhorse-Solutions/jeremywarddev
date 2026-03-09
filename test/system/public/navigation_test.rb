require_relative "../application_system_test_case"

class Public::NavigationTest < ApplicationSystemTestCase
  def test_desktop_nav_shows_home_portfolio_about
    visit root_path

    within "header nav" do
      assert_link "Home", href: root_path
      assert_link "Portfolio", href: portfolio_path
      assert_link "About", href: about_path
    end
  end

  def test_old_placeholder_nav_items_are_removed
    visit root_path

    within "header" do
      assert_no_text "Features"
      assert_no_text "How It Works"
      assert_no_text "Pricing"
      assert_no_text "FAQ"
    end
  end

  def test_mobile_drawer_nav_matches_desktop
    visit root_path

    assert_link "Home", href: root_path
    assert_link "Portfolio", href: portfolio_path
    assert_link "About", href: about_path
  end
end
