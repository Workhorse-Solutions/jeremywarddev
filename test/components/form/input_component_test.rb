require "test_helper"

class Form::InputComponentTest < ViewComponent::TestCase
  # Builds a Rails FormBuilder for the given model instance.
  def build_form(model)
    ActionView::Helpers::FormBuilder.new(
      model.model_name.param_key,
      model,
      vc_test_controller.view_context,
      {}
    )
  end

  # ---------------------------------------------------------------------------
  # Default / text type
  # ---------------------------------------------------------------------------

  def test_renders_text_input_by_default
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email)).to_html
    assert_includes html, 'type="text"'
  end

  # ---------------------------------------------------------------------------
  # HTML5 input types
  # ---------------------------------------------------------------------------

  def test_renders_email_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :email)).to_html
    assert_includes html, 'type="email"'
  end

  def test_renders_password_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :password, type: :password)).to_html
    assert_includes html, 'type="password"'
  end

  def test_renders_tel_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :tel)).to_html
    assert_includes html, 'type="tel"'
  end

  def test_renders_url_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :url)).to_html
    assert_includes html, 'type="url"'
  end

  def test_renders_number_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :number)).to_html
    assert_includes html, 'type="number"'
  end

  def test_renders_search_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :search)).to_html
    assert_includes html, 'type="search"'
  end

  def test_renders_date_field
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :date)).to_html
    assert_includes html, 'type="date"'
  end

  # ---------------------------------------------------------------------------
  # Base CSS classes
  # ---------------------------------------------------------------------------

  def test_includes_base_classes
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :email)).to_html
    assert_includes html, "input"
    assert_includes html, "input-bordered"
    assert_includes html, "w-full"
  end

  # ---------------------------------------------------------------------------
  # Extra input_html options
  # ---------------------------------------------------------------------------

  def test_forwards_autocomplete_option
    f = build_form(User.new)
    html = render_inline(
      Form::InputComponent.new(form: f, attribute: :email, type: :email,
                               input_html: { autocomplete: "email" })
    ).to_html
    assert_includes html, 'autocomplete="email"'
  end

  def test_forwards_placeholder_option
    f = build_form(User.new)
    html = render_inline(
      Form::InputComponent.new(form: f, attribute: :email, type: :email,
                               input_html: { placeholder: "you@example.com" })
    ).to_html
    assert_includes html, 'placeholder="you@example.com"'
  end

  def test_forwards_required_option
    f = build_form(User.new)
    html = render_inline(
      Form::InputComponent.new(form: f, attribute: :email, type: :email,
                               input_html: { required: true })
    ).to_html
    assert_includes html, "required"
  end

  def test_merges_extra_class_with_base_classes
    f = build_form(User.new)
    html = render_inline(
      Form::InputComponent.new(form: f, attribute: :email, type: :email,
                               input_html: { class: "my-extra-class" })
    ).to_html
    assert_includes html, "input-bordered"
    assert_includes html, "my-extra-class"
  end

  # ---------------------------------------------------------------------------
  # Error state
  # ---------------------------------------------------------------------------

  def test_adds_error_class_when_attribute_has_errors
    user = User.new
    user.errors.add(:email, "is invalid")
    f = build_form(user)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :email)).to_html
    assert_includes html, "input-error"
  end

  def test_omits_error_class_when_no_errors
    f = build_form(User.new)
    html = render_inline(Form::InputComponent.new(form: f, attribute: :email, type: :email)).to_html
    refute_includes html, "input-error"
  end

  # ---------------------------------------------------------------------------
  # Unsupported type guard
  # ---------------------------------------------------------------------------

  def test_raises_on_unknown_type
    f = build_form(User.new)
    assert_raises(ArgumentError) do
      Form::InputComponent.new(form: f, attribute: :email, type: :bogus).call
    end
  end
end
