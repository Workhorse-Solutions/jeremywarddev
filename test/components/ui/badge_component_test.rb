require "test_helper"

class UI::BadgeComponentTest < ViewComponent::TestCase
  def test_renders_label_text
    render_inline(UI::BadgeComponent.new(label: "owner", color: :primary))
    assert_selector "span.badge", text: "owner"
  end

  def test_primary_color_applies_badge_primary_class
    result = render_inline(UI::BadgeComponent.new(label: "owner", color: :primary))
    assert_includes result.to_html, "badge-primary"
  end

  def test_secondary_color_applies_badge_secondary_class
    result = render_inline(UI::BadgeComponent.new(label: "admin", color: :secondary))
    assert_includes result.to_html, "badge-secondary"
  end

  def test_ghost_color_applies_badge_ghost_class
    result = render_inline(UI::BadgeComponent.new(label: "member", color: :ghost))
    assert_includes result.to_html, "badge-ghost"
  end

  def test_defaults_to_ghost_color
    result = render_inline(UI::BadgeComponent.new(label: "member"))
    assert_includes result.to_html, "badge-ghost"
  end

  def test_unknown_color_falls_back_to_ghost
    result = render_inline(UI::BadgeComponent.new(label: "x", color: :unknown))
    assert_includes result.to_html, "badge-ghost"
  end
end
