require "test_helper"

class UI::ModalComponentTest < ViewComponent::TestCase
  # --- title ---

  def test_renders_title
    render_inline(UI::ModalComponent.new(title: "My Dialog"))
    assert_text "My Dialog"
  end

  def test_title_is_in_heading
    render_inline(UI::ModalComponent.new(title: "Hello"))
    assert_selector "h3", text: "Hello"
  end

  # --- content ---

  def test_renders_content
    render_inline(UI::ModalComponent.new(title: "T")) { "Body text" }
    assert_text "Body text"
  end

  # --- open state ---

  def test_has_modal_open_class_by_default
    render_inline(UI::ModalComponent.new(title: "T"))
    assert_selector ".modal.modal-open"
  end

  def test_has_modal_open_class_when_open_true
    render_inline(UI::ModalComponent.new(title: "T", open: true))
    assert_selector ".modal.modal-open"
  end

  def test_omits_modal_open_class_when_open_false
    render_inline(UI::ModalComponent.new(title: "T", open: false))
    assert_selector ".modal"
    assert_no_selector ".modal-open"
  end

  # --- size ---

  def test_default_size_is_medium
    render_inline(UI::ModalComponent.new(title: "T"))
    assert_selector ".modal-box.max-w-3xl"
  end

  def test_size_sm
    render_inline(UI::ModalComponent.new(title: "T", size: :sm))
    assert_selector ".modal-box.max-w-lg"
  end

  def test_size_lg
    render_inline(UI::ModalComponent.new(title: "T", size: :lg))
    assert_selector ".modal-box.max-w-4xl"
  end

  # --- close button ---

  def test_close_button_has_default_aria_label
    render_inline(UI::ModalComponent.new(title: "T"))
    assert_selector "button[aria-label='Close']"
  end

  def test_close_button_uses_custom_close_label
    render_inline(UI::ModalComponent.new(title: "T", close_label: "Dismiss"))
    assert_selector "button[aria-label='Dismiss']"
  end

  # --- accessibility ---

  def test_has_dialog_role
    render_inline(UI::ModalComponent.new(title: "T"))
    assert_selector "[role='dialog']"
  end

  def test_has_aria_modal_attribute
    render_inline(UI::ModalComponent.new(title: "T"))
    assert_selector "[aria-modal='true']"
  end

  def test_aria_labelledby_points_to_heading_id
    render_inline(UI::ModalComponent.new(title: "T"))
    labelledby = page.find("[aria-labelledby]")["aria-labelledby"]
    assert_selector "##{labelledby}", text: "T"
  end

  # --- footer slot ---

  def test_footer_not_rendered_when_absent
    render_inline(UI::ModalComponent.new(title: "T"))
    assert_no_selector ".modal-action"
  end

  def test_footer_rendered_when_provided
    render_inline(UI::ModalComponent.new(title: "T")) do |component|
      component.with_footer { "Save" }
    end
    assert_selector ".modal-action", text: "Save"
  end

  # --- dialog mode (id: present) ---

  def test_renders_dialog_element_when_id_given
    render_inline(UI::ModalComponent.new(title: "T", id: "my-dialog"))
    assert_selector "dialog#my-dialog"
  end

  def test_dialog_mode_does_not_render_div_wrapper
    render_inline(UI::ModalComponent.new(title: "T", id: "my-dialog"))
    assert_no_selector "div.modal"
  end

  def test_dialog_mode_open_true_adds_open_attribute
    render_inline(UI::ModalComponent.new(title: "T", id: "my-dialog", open: true))
    assert_selector "dialog[open]"
  end

  def test_dialog_mode_open_false_omits_open_attribute
    render_inline(UI::ModalComponent.new(title: "T", id: "my-dialog", open: false))
    assert_no_selector "dialog[open]"
  end

  def test_dialog_mode_renders_form_method_dialog_backdrop
    render_inline(UI::ModalComponent.new(title: "T", id: "my-dialog"))
    assert_selector "form.modal-backdrop[method='dialog']"
  end

  def test_title_data_attributes_rendered_on_heading
    render_inline(UI::ModalComponent.new(title: "T", id: "my-dialog", title_data: { behavior: "title" }))
    assert_selector "h3[data-behavior='title']"
  end
end
