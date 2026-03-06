require "test_helper"

class UI::ToastComponentTest < ViewComponent::TestCase
  def test_renders_message
    render_inline(UI::ToastComponent.new(message: "Saved successfully"))
    assert_selector "[role='status']", text: "Saved successfully"
  end

  def test_notice_type_renders_success_alert
    render_inline(UI::ToastComponent.new(message: "Done", type: :notice))
    assert_selector ".alert.alert-success"
  end

  def test_success_type_renders_success_alert
    render_inline(UI::ToastComponent.new(message: "Done", type: :success))
    assert_selector ".alert.alert-success"
  end

  def test_alert_type_renders_error_alert
    render_inline(UI::ToastComponent.new(message: "Failed", type: :alert))
    assert_selector ".alert.alert-error"
  end

  def test_error_type_renders_error_alert
    render_inline(UI::ToastComponent.new(message: "Failed", type: :error))
    assert_selector ".alert.alert-error"
  end

  def test_warning_type_renders_warning_alert
    render_inline(UI::ToastComponent.new(message: "Careful", type: :warning))
    assert_selector ".alert.alert-warning"
  end

  def test_unknown_type_renders_info_alert
    render_inline(UI::ToastComponent.new(message: "FYI", type: :custom))
    assert_selector ".alert.alert-info"
  end

  def test_attaches_flash_stimulus_controller
    render_inline(UI::ToastComponent.new(message: "Hi"))
    assert_selector "[data-controller='flash']"
  end

  def test_default_timeout_value
    render_inline(UI::ToastComponent.new(message: "Hi"))
    assert_selector "[data-flash-timeout-value='5000']"
  end

  def test_custom_timeout_value
    render_inline(UI::ToastComponent.new(message: "Hi", timeout_ms: 3000))
    assert_selector "[data-flash-timeout-value='3000']"
  end

  def test_pause_and_resume_actions
    result = render_inline(UI::ToastComponent.new(message: "Hi"))
    assert_includes result.to_html, "mouseenter->flash#pause"
    assert_includes result.to_html, "mouseleave->flash#resume"
  end

  def test_close_button
    render_inline(UI::ToastComponent.new(message: "Hi", close_label: "Dismiss"))
    assert_selector "button[aria-label='Dismiss'][data-action='flash#close']"
  end

  def test_string_type_coercion
    render_inline(UI::ToastComponent.new(message: "Done", type: "notice"))
    assert_selector ".alert.alert-success"
  end
end
