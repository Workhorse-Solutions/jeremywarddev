# Renders a single HTML5 form input using Rails form helpers.
#
# Supports all common input types via the +type:+ parameter.
# Additional HTML attributes (autocomplete:, autofocus:, placeholder:, etc.)
# are forwarded to the underlying form helper via +input_html:+.
#
# Examples:
#   <%= render Form::InputComponent.new(form: f, attribute: :email, type: :email) %>
#   <%= render Form::InputComponent.new(form: f, attribute: :password, type: :password) %>
#   <%= render Form::InputComponent.new(form: f, attribute: :age, type: :number) %>
class Form::InputComponent < ViewComponent::Base
  TYPE_TO_METHOD = {
    text:           :text_field,
    email:          :email_field,
    password:       :password_field,
    tel:            :telephone_field,
    url:            :url_field,
    search:         :search_field,
    number:         :number_field,
    range:          :range_field,
    color:          :color_field,
    date:           :date_field,
    time:           :time_field,
    datetime_local: :datetime_local_field,
    month:          :month_field,
    week:           :week_field
  }.freeze

  # @param form      [ActionView::Helpers::FormBuilder]
  # @param attribute [Symbol, String] model attribute name
  # @param type      [Symbol] HTML5 input type (default: :text)
  # @param input_html [Hash] extra HTML attributes forwarded to the helper
  def initialize(form:, attribute:, type: :text, input_html: {})
    @form       = form
    @attribute  = attribute
    @type       = type.to_sym
    @input_html = input_html
  end

  def call
    form.public_send(helper_method, attribute, **merged_options)
  end

  private

  attr_reader :form, :attribute, :type, :input_html

  def helper_method
    TYPE_TO_METHOD.fetch(type) do
      raise ArgumentError, "Form::InputComponent: unsupported type #{type.inspect}. " \
                           "Valid types: #{TYPE_TO_METHOD.keys.join(', ')}"
    end
  end

  def invalid?
    form.object&.errors&.[](attribute)&.present? || false
  end

  def merged_options
    input_html.deep_dup.tap do |opts|
      opts[:class] = merged_class(opts[:class])
    end
  end

  def merged_class(extra)
    [
      "input input-bordered w-full",
      ("input-error" if invalid?),
      extra
    ].compact.join(" ")
  end
end
