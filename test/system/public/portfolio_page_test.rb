require_relative "../application_system_test_case"

class Public::PortfolioPageTest < ApplicationSystemTestCase
  def test_portfolio_page_displays_compact_hero
    visit portfolio_path

    assert_selector "h1", text: "Services & Portfolio"
  end

  def test_portfolio_page_displays_services_section
    visit portfolio_path

    assert_selector "h2", text: "Services"
    assert_text "Ruby on Rails development"
    assert_text "SaaS architecture"
    assert_text "AI-native development"
    assert_text "Solo founder technical strategy"
  end

  def test_portfolio_page_displays_project_cards
    visit portfolio_path

    assert_selector ".card", minimum: 6
    assert_text "GetBackTo"
    assert_text "CoverText"
    assert_text "RailsFoundry"
    assert_text "WorkhorseOps"
    assert_text "Workhorse Compliance"
    assert_text "RFP/Grant Ecosystem"
  end

  def test_portfolio_page_displays_philosophy_blurb
    visit portfolio_path

    assert_text "I build tools that work for solo founders"
    assert_text "build leverage so I can work less and live more"
  end
end
