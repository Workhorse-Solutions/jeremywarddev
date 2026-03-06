require "test_helper"

class UI::CardComponentTest < ViewComponent::TestCase
  def test_renders_default_card_structure
    render_inline(UI::CardComponent.new) { "Hello" }
    assert_selector "div.card.bg-base-100"
    assert_selector "div.card-body"
    assert_text "Hello"
  end

  def test_appends_class_name_to_outer
    render_inline(UI::CardComponent.new(class_name: "w-full")) { "" }
    assert_selector "div.card.w-full"
  end

  def test_appends_body_class_to_card_body
    render_inline(UI::CardComponent.new(body_class: "gap-6")) { "" }
    assert_selector "div.card-body.gap-6"
  end

  def test_outer_class_fully_overrides_default_outer_classes
    render_inline(UI::CardComponent.new(outer_class: "custom-card")) { "" }
    assert_selector "div.custom-card"
    assert_no_selector "div.card"
  end

  def test_custom_tag_renders_correct_element
    render_inline(UI::CardComponent.new(tag: :section)) { "" }
    assert_selector "section.card"
    assert_no_selector "div.card"
  end

  def test_passes_extra_html_attributes
    render_inline(UI::CardComponent.new(id: "my-card", data: { controller: "card" })) { "" }
    assert_selector "div#my-card"
    assert_selector "div[data-controller='card']"
  end
end
