require_relative "../application_system_test_case"

class Public::HomePageTest < ApplicationSystemTestCase
  def test_home_page_displays_hero_with_heading_and_cta
    visit root_path

    assert_selector "h1", text: "Jeremy Ward"
    assert_selector "p", text: /Rails \+ AI/
    assert_selector "a.btn.btn-primary", text: "View Services & Portfolio"
  end

  def test_home_page_displays_intro_section
    visit root_path

    assert_text "I'm a Rails developer with 20 years of experience"
  end

  def test_home_page_cta_links_to_portfolio
    visit root_path

    assert_selector "a[href='#{portfolio_path}']", text: "View Services & Portfolio"
  end
end
