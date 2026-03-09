require "test_helper"

class UI::Public::HeroComponentTest < ViewComponent::TestCase
  def test_large_variant_renders_prominent_heading
    render_inline(UI::Public::HeroComponent.new(title: "Welcome", subtitle: "Hello world", size: :large))
    assert_selector "h1.text-5xl", text: "Welcome"
  end

  def test_large_variant_renders_subtitle
    render_inline(UI::Public::HeroComponent.new(title: "Welcome", subtitle: "Hello world", size: :large))
    assert_selector "p.text-xl", text: "Hello world"
  end

  def test_large_variant_renders_cta_button
    render_inline(UI::Public::HeroComponent.new(
      title: "Welcome", size: :large, cta_label: "Get Started", cta_href: "/portfolio"
    ))
    assert_selector "a.btn.btn-primary.btn-lg", text: "Get Started"
    assert_selector "a[href='/portfolio']"
  end

  def test_compact_variant_renders_smaller_heading
    render_inline(UI::Public::HeroComponent.new(title: "About", size: :compact))
    assert_selector "h1.text-3xl", text: "About"
  end

  def test_compact_variant_renders_optional_subtitle
    render_inline(UI::Public::HeroComponent.new(title: "About", subtitle: "Learn more", size: :compact))
    assert_selector "p.text-lg", text: "Learn more"
  end

  def test_compact_variant_does_not_render_cta
    render_inline(UI::Public::HeroComponent.new(
      title: "About", size: :compact, cta_label: "Click", cta_href: "/x"
    ))
    assert_no_selector "a.btn"
  end

  def test_large_variant_uses_larger_padding
    render_inline(UI::Public::HeroComponent.new(title: "Test", size: :large))
    assert_selector "section.py-20"
  end

  def test_compact_variant_uses_smaller_padding
    render_inline(UI::Public::HeroComponent.new(title: "Test", size: :compact))
    assert_selector "section.py-12"
  end

  def test_omits_subtitle_when_not_provided
    render_inline(UI::Public::HeroComponent.new(title: "Test"))
    assert_no_selector "p"
  end

  def test_omits_cta_when_label_missing
    render_inline(UI::Public::HeroComponent.new(title: "Test", size: :large, cta_href: "/x"))
    assert_no_selector "a.btn"
  end
end
