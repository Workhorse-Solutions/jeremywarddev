require "test_helper"

class UI::Authenticated::EmailVerificationBannerComponentTest < ViewComponent::TestCase
  def test_renders_when_not_verified
    render_inline(UI::Authenticated::EmailVerificationBannerComponent.new(verified: false))
    assert_selector "[data-testid='email-verification-banner']"
    assert_text I18n.t("authenticated.email_verification_banner.message")
  end

  def test_renders_resend_button
    render_inline(UI::Authenticated::EmailVerificationBannerComponent.new(verified: false))
    assert_selector "button", text: I18n.t("authenticated.email_verification_banner.resend")
  end

  def test_has_dom_id_for_turbo_stream
    render_inline(UI::Authenticated::EmailVerificationBannerComponent.new(verified: false))
    assert_selector "#email-verification-banner"
  end

  def test_does_not_render_when_verified
    render_inline(UI::Authenticated::EmailVerificationBannerComponent.new(verified: true))
    assert_no_selector "[data-testid='email-verification-banner']"
  end

  def test_has_alert_role
    render_inline(UI::Authenticated::EmailVerificationBannerComponent.new(verified: false))
    assert_selector "[role='alert']"
  end
end
