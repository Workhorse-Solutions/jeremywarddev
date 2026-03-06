require "test_helper"

class UI::PricingCardComponentTest < ViewComponent::TestCase
  def default_params
    {
      name: "Pro",
      price: "$49/mo",
      tagline: "Great for teams",
      cta_text: "Get started",
      cta_href: "/dashboard",
      features: [ "Feature one", "Feature two", "Feature three" ]
    }
  end

  def test_renders_name
    html = render_inline(UI::PricingCardComponent.new(**default_params)).to_html
    assert_includes html, "Pro"
  end

  def test_renders_price
    html = render_inline(UI::PricingCardComponent.new(**default_params)).to_html
    assert_includes html, "$49/mo"
  end

  def test_renders_tagline
    html = render_inline(UI::PricingCardComponent.new(**default_params)).to_html
    assert_includes html, "Great for teams"
  end

  def test_renders_features_as_list
    html = render_inline(UI::PricingCardComponent.new(**default_params)).to_html
    assert_includes html, "Feature one"
    assert_includes html, "Feature two"
    assert_selector "ul"
    assert_selector "li"
  end

  def test_renders_cta_link
    html = render_inline(UI::PricingCardComponent.new(**default_params)).to_html
    assert_includes html, "/dashboard"
    assert_includes html, "Get started"
  end

  def test_highlighted_card_uses_primary_bg
    html = render_inline(UI::PricingCardComponent.new(**default_params, highlighted: true)).to_html
    assert_includes html, "bg-primary"
  end

  def test_badge_renders_when_present
    html = render_inline(UI::PricingCardComponent.new(**default_params, badge: "Most popular")).to_html
    assert_includes html, "Most popular"
  end

  def test_no_badge_by_default
    html = render_inline(UI::PricingCardComponent.new(**default_params)).to_html
    refute_includes html, "Most popular"
  end
end
