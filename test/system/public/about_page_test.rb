require_relative "../application_system_test_case"

class Public::AboutPageTest < ApplicationSystemTestCase
  def test_about_page_displays_compact_hero
    visit about_path

    assert_selector "h1", text: "About"
  end

  def test_about_page_displays_bio_content
    visit about_path

    assert_text "I'm Jeremy Ward"
    assert_text "What's different"
    assert_text "Background"
    assert_text "Philosophy"
    assert_text "What's here"
  end

  def test_about_page_displays_social_links
    visit about_path

    assert_selector "a[href='https://x.com/jrmyward']"
    assert_selector "a[href='https://linkedin.com/in/jrmyward']"
    assert_selector "a[href='https://youtube.com/@jeremywarddev']"
    assert_selector "a[href='https://github.com/Workhorse-Solutions']"
    assert_text "@jeremywarddev"
    assert_text "in/jrmyward"
  end
end
