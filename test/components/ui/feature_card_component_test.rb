require "test_helper"

class UI::FeatureCardComponentTest < ViewComponent::TestCase
  def test_renders_title
    render_inline(UI::FeatureCardComponent.new(title: "Feature One", description: "This is a feature."))
    assert_selector "h3", text: "Feature One"
  end

  def test_renders_description
    render_inline(UI::FeatureCardComponent.new(title: "Feature One", description: "This is a feature."))
    assert_text "This is a feature."
  end

  def test_card_structure
    render_inline(UI::FeatureCardComponent.new(title: "Test", description: "Desc"))
    assert_selector "div.card.bg-base-200"
    assert_selector "div.card-body"
  end

  def test_icon_placeholder_present
    render_inline(UI::FeatureCardComponent.new(title: "Test", description: "Desc"))
    assert_selector "div.bg-primary\\/10.rounded-lg"
  end
end
