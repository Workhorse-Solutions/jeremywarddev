require "test_helper"

class UI::Public::HeroComponentTest < ViewComponent::TestCase
  def test_large_variant_renders_prominent_heading
    render_inline(UI::Public::HeroComponent.new(title: "Welcome", subtitle: "Hello world", size: :large))
    assert_selector "h1", text: "Welcome"
  end

  def test_large_variant_renders_subtitle
    render_inline(UI::Public::HeroComponent.new(title: "Welcome", subtitle: "Hello world", size: :large))
    assert_text "Hello world"
  end

  def test_large_variant_renders_cta_link
    render_inline(UI::Public::HeroComponent.new(
      title: "Welcome", size: :large, cta_label: "Get Started", cta_href: "/portfolio"
    ))
    assert_selector "a[href='/portfolio']"
    assert_text "Get Started"
  end

  def test_compact_variant_renders_heading
    render_inline(UI::Public::HeroComponent.new(title: "About", size: :compact))
    assert_selector "h1", text: "About"
  end

  def test_compact_variant_does_not_render_cta
    render_inline(UI::Public::HeroComponent.new(
      title: "About", size: :compact, cta_label: "Click", cta_href: "/x"
    ))
    assert_no_selector "a"
  end

  def test_large_variant_renders_section
    render_inline(UI::Public::HeroComponent.new(title: "Test", size: :large))
    assert_selector "section"
  end

  def test_compact_variant_renders_section
    render_inline(UI::Public::HeroComponent.new(title: "Test", size: :compact))
    assert_selector "section"
  end

  def test_omits_cta_when_label_missing
    render_inline(UI::Public::HeroComponent.new(title: "Test", size: :large, cta_href: "/x"))
    assert_no_selector "a"
  end
end
