require "test_helper"

class UI::ToastsComponentTest < ViewComponent::TestCase
  def test_renders_flash_messages
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = "Saved"
    flash[:alert] = "Something went wrong"

    render_inline(UI::ToastsComponent.new(flash: flash))

    assert_selector ".toast.toast-top.toast-end"
    assert_selector ".alert", count: 2
    assert_selector ".alert-success", text: "Saved"
    assert_selector ".alert-error", text: "Something went wrong"
  end

  def test_does_not_render_when_flash_is_empty
    flash = ActionDispatch::Flash::FlashHash.new

    result = render_inline(UI::ToastsComponent.new(flash: flash))

    assert_equal "", result.to_html.strip
  end

  def test_skips_blank_messages
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = ""
    flash[:alert] = "Error"

    render_inline(UI::ToastsComponent.new(flash: flash))

    assert_selector ".alert", count: 1
    assert_selector ".alert-error", text: "Error"
  end

  def test_passes_custom_timeout_to_toasts
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = "Hi"

    render_inline(UI::ToastsComponent.new(flash: flash, timeout_ms: 3000))

    assert_selector "[data-flash-timeout-value='3000']"
  end

  def test_passes_close_label_to_toasts
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = "Hi"

    render_inline(UI::ToastsComponent.new(flash: flash, close_label: "Dismiss"))

    assert_selector "button[aria-label='Dismiss']"
  end
end
