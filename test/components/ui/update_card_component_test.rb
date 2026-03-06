require "test_helper"

class UI::UpdateCardComponentTest < ViewComponent::TestCase
  def test_renders_date
    render_inline(UI::UpdateCardComponent.new(date: "March 2025", title: "Update Title", description: "Description."))
    assert_text "March 2025"
  end

  def test_renders_title
    render_inline(UI::UpdateCardComponent.new(date: "March 2025", title: "Update Title", description: "Description."))
    assert_selector "h3", text: "Update Title"
  end

  def test_renders_description
    render_inline(UI::UpdateCardComponent.new(date: "March 2025", title: "Update Title", description: "Description."))
    assert_text "Description."
  end

  def test_card_structure
    render_inline(UI::UpdateCardComponent.new(date: "Jan 2025", title: "Test", description: "Desc"))
    assert_selector "div.card.bg-base-100"
    assert_selector "div.card-body"
  end
end
