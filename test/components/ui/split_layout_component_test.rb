require "test_helper"

class UI::SplitLayoutComponentTest < ViewComponent::TestCase
  def test_default_renders_text_then_visual
    result = render_inline(UI::SplitLayoutComponent.new) do |c|
      c.with_text_column { "Text Content" }
      c.with_visual_column { "Visual Content" }
    end
    html = result.to_html
    assert html.index("Text Content") < html.index("Visual Content"),
           "Text column should appear before visual column in DOM"
  end

  def test_reversed_renders_visual_then_text
    result = render_inline(UI::SplitLayoutComponent.new(reversed: true)) do |c|
      c.with_text_column { "Text Content" }
      c.with_visual_column { "Visual Content" }
    end
    html = result.to_html
    assert html.index("Visual Content") < html.index("Text Content"),
           "Visual column should appear before text column in DOM"
  end

  def test_hide_visual_on_mobile_adds_hidden_class
    result = render_inline(UI::SplitLayoutComponent.new(hide_visual_on_mobile: true)) do |c|
      c.with_text_column { "Text" }
      c.with_visual_column { "Visual" }
    end
    assert_includes result.to_html, "hidden lg:flex items-center justify-center"
  end

  def test_no_hide_class_when_hide_visual_on_mobile_false
    result = render_inline(UI::SplitLayoutComponent.new(hide_visual_on_mobile: false)) do |c|
      c.with_text_column { "Text" }
      c.with_visual_column { "Visual" }
    end
    refute_includes result.to_html, "hidden"
  end

  def test_outer_wrapper_grid_classes
    result = render_inline(UI::SplitLayoutComponent.new) do |c|
      c.with_text_column { "" }
      c.with_visual_column { "" }
    end
    assert_includes result.to_html, "grid grid-cols-1 lg:grid-cols-2 gap-12 items-center"
  end

  def test_renders_slot_content
    render_inline(UI::SplitLayoutComponent.new) do |c|
      c.with_text_column { "Hello from text" }
      c.with_visual_column { "Hello from visual" }
    end
    assert_text "Hello from text"
    assert_text "Hello from visual"
  end
end
