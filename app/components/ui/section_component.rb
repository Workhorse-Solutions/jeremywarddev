class UI::SectionComponent < ViewComponent::Base
  DEFAULT_OUTER_CLASSES = "py-20".freeze
  DEFAULT_INNER_CLASSES = "container".freeze

  BACKGROUND_COLORS = {
    none: "",
    light: "bg-base-200",
    dark: "bg-base-300",
    primary: "bg-primary text-primary-content"
  }.freeze

  # @param bg [Symbol, String] background color preset (:none, :light, :dark, :primary) or custom classes
  # @param py [String, nil] vertical padding override (default: "py-20")
  # @param class_name [String, nil] extra classes appended to the outer section wrapper
  # @param inner_class [String, nil] extra classes appended to the inner container
  # @param outer_class [String, nil] full override for outer classes (use sparingly)
  # @param html_tag [Symbol] HTML tag for the outer wrapper (default: :section)
  # @param kwargs [Hash] any extra HTML attributes (id:, data:, aria:, etc.)
  def initialize(bg: :none, py: nil, class_name: nil, inner_class: nil, outer_class: nil, html_tag: :section, **kwargs)
    @bg = bg
    @py = py
    @class_name = class_name
    @inner_class = inner_class
    @outer_class = outer_class
    @html_tag = html_tag
    @kwargs = kwargs
  end

  private

  attr_reader :bg, :py, :class_name, :inner_class, :outer_class, :html_tag, :kwargs

  def outer_classes
    if outer_class.present?
      outer_class
    else
      [
        background_classes,
        py || DEFAULT_OUTER_CLASSES,
        class_name
      ].compact_blank.join(" ")
    end
  end

  def inner_classes
    [ DEFAULT_INNER_CLASSES, inner_class ].compact_blank.join(" ")
  end

  def background_classes
    if bg.is_a?(Symbol)
      BACKGROUND_COLORS.fetch(bg, "")
    else
      bg.to_s
    end
  end
end
