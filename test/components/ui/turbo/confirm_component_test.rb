require "test_helper"

class UI::Turbo::ConfirmComponentTest < ViewComponent::TestCase
  def component
    UI::Turbo::ConfirmComponent.new(confirm_label: "Yes, delete", cancel_label: "Cancel")
  end

  # --- native dialog element ---

  def test_renders_native_dialog
    render_inline(component)
    assert_selector "dialog#turbo-confirm"
  end

  def test_dialog_is_not_open_on_load
    render_inline(component)
    assert_no_selector "dialog[open]"
  end

  # --- data-behavior hooks for JS ---

  def test_title_hook_is_present
    render_inline(component)
    assert_selector "[data-behavior='title']"
  end

  def test_description_hook_is_present
    render_inline(component)
    assert_selector "[data-behavior='description']"
  end

  def test_instructions_hook_is_present
    render_inline(component)
    assert_selector "[data-behavior='instructions']"
  end

  def test_confirm_text_input_is_present
    render_inline(component)
    assert_selector "input[data-behavior='confirm-text']"
  end

  # --- buttons ---

  def test_confirm_button_has_correct_value_and_label
    render_inline(component)
    assert_selector "button[value='confirm']", text: "Yes, delete"
  end

  def test_cancel_button_label
    render_inline(component)
    assert_selector ".modal-action button[value='']", text: "Cancel"
  end

  def test_confirm_label_is_configurable
    render_inline(UI::Turbo::ConfirmComponent.new(confirm_label: "Remove", cancel_label: "Keep"))
    assert_selector "button[value='confirm']", text: "Remove"
  end

  def test_cancel_label_is_configurable
    render_inline(UI::Turbo::ConfirmComponent.new(confirm_label: "Remove", cancel_label: "Keep"))
    assert_selector ".modal-action button[value='']", text: "Keep"
  end

  # --- backdrop ---

  def test_renders_modal_backdrop_form
    render_inline(component)
    assert_selector "form.modal-backdrop[method='dialog']"
  end
end
