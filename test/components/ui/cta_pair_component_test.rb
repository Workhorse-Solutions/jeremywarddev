require "test_helper"

class UI::CtaPairComponentTest < ViewComponent::TestCase
  def default_component
    UI::CtaPairComponent.new(
      primary_text: "Get Started",
      primary_href: "/dashboard",
      secondary_text: "See Pricing",
      secondary_href: "/pricing"
    )
  end

  def test_renders_primary_link
    render_inline(default_component)
    assert_selector "a[href='/dashboard']", text: "Get Started"
  end

  def test_renders_secondary_link
    render_inline(default_component)
    assert_selector "a[href='/pricing']", text: "See Pricing"
  end

  def test_default_variant_primary_button
    render_inline(default_component)
    assert_selector "a.btn-primary"
  end

  def test_default_variant_secondary_button
    render_inline(default_component)
    assert_selector "a.btn-outline"
  end

  def test_inverted_variant_primary_button
    render_inline(UI::CtaPairComponent.new(
      primary_text: "Start",
      primary_href: "/dashboard",
      secondary_text: "Pricing",
      secondary_href: "/pricing",
      variant: :inverted
    ))
    assert_selector "a.bg-white.text-primary"
  end

  def test_inverted_variant_secondary_button
    result = render_inline(UI::CtaPairComponent.new(
      primary_text: "Start",
      primary_href: "/dashboard",
      secondary_text: "Pricing",
      secondary_href: "/pricing",
      variant: :inverted
    ))
    assert_includes result.to_html, "text-white"
  end

  def test_start_justify
    result = render_inline(default_component)
    assert_includes result.to_html, "flex flex-wrap gap-3"
    refute_includes result.to_html, "justify-center"
  end

  def test_center_justify
    result = render_inline(UI::CtaPairComponent.new(
      primary_text: "Start",
      primary_href: "/dashboard",
      secondary_text: "Pricing",
      secondary_href: "/pricing",
      justify: :center
    ))
    assert_includes result.to_html, "justify-center"
  end

  def test_buttons_are_anchor_tags
    render_inline(default_component)
    assert_selector "a", count: 2
    assert_no_selector "button"
  end
end
