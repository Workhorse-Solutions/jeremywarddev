require "test_helper"

class UI::CardGridComponentTest < ViewComponent::TestCase
  def test_renders_3_col_grid_by_default
    result = render_inline(UI::CardGridComponent.new) { "cards" }
    assert_includes result.to_html, "lg:grid-cols-3"
  end

  def test_renders_2_col_grid
    result = render_inline(UI::CardGridComponent.new(cols: 2)) { "cards" }
    assert_includes result.to_html, "md:grid-cols-2"
    refute_includes result.to_html, "lg:grid-cols-3"
  end

  def test_wrapper_class_appended
    result = render_inline(UI::CardGridComponent.new(wrapper_class: "max-w-5xl mx-auto")) { "cards" }
    assert_includes result.to_html, "max-w-5xl mx-auto"
  end

  def test_no_wrapper_class_by_default
    result = render_inline(UI::CardGridComponent.new) { "cards" }
    refute_includes result.to_html, "max-w-5xl"
  end

  def test_renders_content
    render_inline(UI::CardGridComponent.new) { "content inside" }
    assert_text "content inside"
  end

  def test_renders_4_col_grid
    result = render_inline(UI::CardGridComponent.new(cols: 4)) { "cards" }
    assert_includes result.to_html, "lg:grid-cols-4"
    refute_includes result.to_html, "lg:grid-cols-3"
  end

  def test_base_grid_classes_present
    result = render_inline(UI::CardGridComponent.new) { "" }
    assert_includes result.to_html, "grid gap-6"
  end
end
