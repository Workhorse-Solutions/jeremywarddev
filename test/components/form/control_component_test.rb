require "test_helper"

class Form::ControlComponentTest < ViewComponent::TestCase
  # Builds a Rails FormBuilder for the given model instance.
  def build_form(model)
    ActionView::Helpers::FormBuilder.new(
      model.model_name.param_key,
      model,
      vc_test_controller.view_context,
      {}
    )
  end

  def build_component(form: build_form(User.new), attribute: :email, **opts, &block)
    component = Form::ControlComponent.new(form: form, attribute: attribute, **opts)
    if block
      render_inline(component, &block)
    else
      render_inline(component)
    end
  end

  # ---------------------------------------------------------------------------
  # Outer wrapper
  # ---------------------------------------------------------------------------

  def test_renders_form_control_wrapper
    doc = build_component
    assert doc.at_css("div.form-control"), "expected a div.form-control wrapper"
  end

  # ---------------------------------------------------------------------------
  # Label
  # ---------------------------------------------------------------------------

  def test_renders_label_element
    doc = build_component
    assert doc.at_css("label"), "expected a <label> element"
  end

  def test_label_has_expected_classes
    doc = build_component
    label = doc.at_css("label")
    assert_includes label["class"], "label"
    assert_includes label["class"], "font-semibold"
  end

  def test_label_text_defaults_to_humanized_attribute
    doc = build_component(attribute: :email)
    assert_includes doc.at_css("label").text.strip, "Email"
  end

  def test_custom_label_is_rendered
    doc = build_component(attribute: :email, label: "E-mail address")
    assert_includes doc.at_css("label").text, "E-mail address"
  end

  # ---------------------------------------------------------------------------
  # Input slot
  # ---------------------------------------------------------------------------

  def test_renders_content_from_input_slot
    f = build_form(User.new)
    component = Form::ControlComponent.new(form: f, attribute: :email)
    doc = render_inline(component) do |ctrl|
      ctrl.with_input { "<input data-test='slot' />".html_safe }
    end
    assert doc.at_css("input[data-test='slot']"), "expected slot content to be rendered"
  end

  def test_no_input_slot_renders_nothing_for_input
    doc = build_component
    # No input slot provided — the slot area should simply be empty/absent
    refute doc.at_css("input"), "expected no <input> when slot is not filled"
  end

  # ---------------------------------------------------------------------------
  # Hint
  # ---------------------------------------------------------------------------

  def test_hint_not_rendered_when_absent
    doc = build_component
    refute doc.at_css("p.text-base-content\\/60"), "hint paragraph should not appear without hint:"
  end

  def test_hint_is_rendered_when_provided
    doc = build_component(hint: "We'll never share your email.")
    hint = doc.css("p").find { |p| p.text.include?("We'll never share your email.") }
    assert hint, "expected hint paragraph to be rendered"
  end

  def test_hint_has_expected_classes
    doc = build_component(hint: "Some helpful text")
    p_tags = doc.css("p")
    hint_p = p_tags.find { |p| p.text.include?("Some helpful text") }
    assert hint_p, "expected hint to be present"
    assert_includes hint_p["class"], "text-xs"
  end

  # ---------------------------------------------------------------------------
  # Error state
  # ---------------------------------------------------------------------------

  def test_no_errors_shown_when_attribute_is_valid
    doc = build_component
    refute doc.at_css("p.text-error"), "error paragraph should not appear when attribute is valid"
  end

  def test_error_messages_are_rendered
    user = User.new
    user.errors.add(:email, "is invalid")
    user.errors.add(:email, "is too short")
    f = build_form(user)
    component = Form::ControlComponent.new(form: f, attribute: :email)
    doc = render_inline(component)
    error_paras = doc.css("p.text-error")
    assert_equal 2, error_paras.size
    texts = error_paras.map(&:text)
    assert texts.any? { |t| t.include?("is invalid") }
    assert texts.any? { |t| t.include?("is too short") }
  end

  def test_error_wrapper_uses_error_classes
    user = User.new
    user.errors.add(:email, "can't be blank")
    f = build_form(user)
    doc = render_inline(Form::ControlComponent.new(form: f, attribute: :email))
    assert doc.at_css("p.text-error"), "expected an error paragraph with text-error class"
  end

  # ---------------------------------------------------------------------------
  # invalid? helper
  # ---------------------------------------------------------------------------

  def test_invalid_returns_false_when_no_errors
    f = build_form(User.new)
    component = Form::ControlComponent.new(form: f, attribute: :email)
    refute component.invalid?
  end

  def test_invalid_returns_true_when_errors_present
    user = User.new
    user.errors.add(:email, "is invalid")
    f = build_form(user)
    component = Form::ControlComponent.new(form: f, attribute: :email)
    assert component.invalid?
  end

  # ---------------------------------------------------------------------------
  # error_messages helper
  # ---------------------------------------------------------------------------

  def test_error_messages_returns_empty_array_without_errors
    f = build_form(User.new)
    component = Form::ControlComponent.new(form: f, attribute: :email)
    assert_equal [], component.error_messages
  end

  def test_error_messages_returns_full_messages_for_attribute
    user = User.new
    user.errors.add(:email, "is invalid")
    f = build_form(user)
    component = Form::ControlComponent.new(form: f, attribute: :email)
    messages = component.error_messages
    assert_equal 1, messages.size
    assert_includes messages.first, "Email"
    assert_includes messages.first, "is invalid"
  end
end
