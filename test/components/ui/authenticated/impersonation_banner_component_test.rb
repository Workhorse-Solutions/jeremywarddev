require "test_helper"

class UI::Authenticated::ImpersonationBannerComponentTest < ViewComponent::TestCase
  def test_renders_when_active
    render_inline(UI::Authenticated::ImpersonationBannerComponent.new(
      active: true,
      message: "Impersonating Alice",
      stop_label: "Stop",
      stop_href: "/admin/impersonation"
    ))
    assert_selector "[data-testid='impersonation-banner']"
    assert_text "Impersonating Alice"
  end

  def test_renders_stop_button
    render_inline(UI::Authenticated::ImpersonationBannerComponent.new(
      active: true,
      message: "Impersonating Alice",
      stop_label: "Stop",
      stop_href: "/admin/impersonation"
    ))
    assert_selector "button", text: "Stop"
  end

  def test_does_not_render_when_inactive
    render_inline(UI::Authenticated::ImpersonationBannerComponent.new(
      active: false,
      message: "Impersonating Alice",
      stop_label: "Stop",
      stop_href: "/admin/impersonation"
    ))
    assert_no_selector "[data-testid='impersonation-banner']"
  end

  def test_has_warning_styling
    result = render_inline(UI::Authenticated::ImpersonationBannerComponent.new(
      active: true,
      message: "Impersonating Alice",
      stop_label: "Stop",
      stop_href: "/admin/impersonation"
    ))
    assert_includes result.to_html, "bg-warning"
    assert_includes result.to_html, "text-warning-content"
  end
end
