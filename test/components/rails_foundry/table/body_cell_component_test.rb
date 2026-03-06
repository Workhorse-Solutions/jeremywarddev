require "test_helper"

class RailsFoundry::Table::BodyCellComponentTest < ViewComponent::TestCase
  # Renders yielded content inside a td
  def test_renders_td_with_yielded_content
    render_inline(RailsFoundry::Table::BodyCellComponent.new.with_content("Alice"))

    assert_selector "td", text: "Alice"
  end

  # visible: false renders nothing
  def test_visible_false_renders_nothing
    render_inline(RailsFoundry::Table::BodyCellComponent.new(visible: false).with_content("Alice"))

    assert_no_selector "td"
  end
end
