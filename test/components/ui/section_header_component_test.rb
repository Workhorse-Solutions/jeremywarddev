require "test_helper"

class UI::SectionHeaderComponentTest < ViewComponent::TestCase
  def test_renders_heading
    render_inline(UI::SectionHeaderComponent.new(heading: "Welcome"))
    assert_selector "h2", text: "Welcome"
  end

  def test_default_tag_is_h2
    render_inline(UI::SectionHeaderComponent.new(heading: "Test"))
    assert_selector "h2"
    assert_no_selector "h1"
  end

  def test_h1_tag
    render_inline(UI::SectionHeaderComponent.new(heading: "Big Title", tag: :h1))
    assert_selector "h1", text: "Big Title"
    assert_no_selector "h2"
  end

  def test_label_rendered_when_provided
    render_inline(UI::SectionHeaderComponent.new(heading: "Test", label: "Section Label"))
    assert_selector "p", text: "Section Label"
  end

  def test_label_omitted_when_not_provided
    render_inline(UI::SectionHeaderComponent.new(heading: "Test"))
    assert_no_selector "p"
  end

  def test_subheading_rendered_when_provided
    render_inline(UI::SectionHeaderComponent.new(heading: "Test", subheading: "Sub text here"))
    assert_selector "p", text: "Sub text here"
  end

  def test_subheading_omitted_when_not_provided
    render_inline(UI::SectionHeaderComponent.new(heading: "Test"))
    assert_no_selector "p"
  end

  def test_center_alignment_by_default
    render_inline(UI::SectionHeaderComponent.new(heading: "Test"))
    assert_selector "div.text-center"
  end

  def test_left_alignment_removes_text_center
    render_inline(UI::SectionHeaderComponent.new(heading: "Test", align: :left))
    assert_no_selector "div.text-center"
  end

  def test_custom_label_class
    render_inline(UI::SectionHeaderComponent.new(
      heading: "Test",
      label: "Label",
      label_class: "font-semibold uppercase tracking-wider text-sm opacity-60 mb-8"
    ))
    assert_selector "p.opacity-60", text: "Label"
  end

  def test_full_render_all_params
    render_inline(UI::SectionHeaderComponent.new(
      heading: "Main Heading",
      tag: :h1,
      label: "The Label",
      subheading: "The Subheading",
      align: :center
    ))
    assert_selector "h1", text: "Main Heading"
    assert_selector "p", text: "The Label"
    assert_selector "p", text: "The Subheading"
  end

  def test_default_heading_class_applied
    render_inline(UI::SectionHeaderComponent.new(heading: "Test"))
    assert_selector "h2.font-bold"
  end

  def test_custom_heading_class
    result = render_inline(UI::SectionHeaderComponent.new(
      heading: "Hero Title",
      tag: :h1,
      heading_class: "text-5xl font-extrabold"
    ))
    assert_includes result.to_html, "text-5xl font-extrabold"
  end
end
