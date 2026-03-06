require "test_helper"

class UI::SectionComponentTest < ViewComponent::TestCase
  def test_renders_default_tag_and_padding
    render_inline(UI::SectionComponent.new) { "Hello" }
    assert_selector "section.py-20"
  end

  def test_renders_content_in_container
    render_inline(UI::SectionComponent.new) { "Hello" }
    assert_selector "section > div.container", text: "Hello"
  end

  def test_default_bg_is_none
    render_inline(UI::SectionComponent.new) { "" }
    assert_no_selector "section[class~='bg-base-100']"
    assert_no_selector "section[class~='bg-base-200']"
  end

  # Background presets
  def test_bg_light_preset
    render_inline(UI::SectionComponent.new(bg: :light)) { "" }
    assert_selector "section.bg-base-200"
  end

  def test_bg_dark_preset
    render_inline(UI::SectionComponent.new(bg: :dark)) { "" }
    assert_selector "section.bg-base-300"
  end

  def test_bg_primary_preset
    render_inline(UI::SectionComponent.new(bg: :primary)) { "" }
    assert_selector "section.bg-primary.text-primary-content"
  end

  def test_bg_custom_string
    render_inline(UI::SectionComponent.new(bg: "bg-red-500")) { "" }
    assert_selector "section.bg-red-500"
  end

  # Padding
  def test_custom_py
    render_inline(UI::SectionComponent.new(py: "py-10")) { "" }
    assert_selector "section.py-10"
    assert_no_selector "section.py-20"
  end

  # Outer classes
  def test_class_name_appended
    render_inline(UI::SectionComponent.new(class_name: "border-y border-base-200")) { "" }
    assert_selector "section.border-y"
  end

  def test_outer_class_full_override
    render_inline(UI::SectionComponent.new(outer_class: "my-custom-class")) { "" }
    assert_selector "section.my-custom-class"
    assert_no_selector "section.py-20"
  end

  # Inner classes
  def test_inner_class_appended_to_container
    render_inline(UI::SectionComponent.new(inner_class: "px-4")) { "" }
    assert_selector "section > div.container.px-4"
  end

  # Extra HTML attributes via kwargs
  def test_id_attribute
    render_inline(UI::SectionComponent.new(id: "features")) { "" }
    assert_selector "section#features"
  end

  def test_id_omitted_when_not_provided
    render_inline(UI::SectionComponent.new) { "" }
    assert_no_selector "section[id]"
  end

  def test_data_attribute
    render_inline(UI::SectionComponent.new(data: { controller: "scroll" })) { "" }
    assert_selector "section[data-controller='scroll']"
  end

  # Custom wrapper tag
  def test_custom_html_tag
    render_inline(UI::SectionComponent.new(html_tag: :div)) { "" }
    assert_selector "div.py-20"
    assert_no_selector "section"
  end
end
