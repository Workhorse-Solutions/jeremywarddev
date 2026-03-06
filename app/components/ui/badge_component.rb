class UI::BadgeComponent < ViewComponent::Base
  COLOR_MAP = {
    primary: "badge-primary",
    secondary: "badge-secondary",
    accent: "badge-accent",
    ghost: "badge-ghost",
    info: "badge-info",
    success: "badge-success",
    warning: "badge-warning",
    error: "badge-error"
  }.freeze

  def initialize(label:, color: :ghost)
    @label = label
    @color = color
  end

  private

  attr_reader :label, :color

  def badge_class
    [ "badge", COLOR_MAP.fetch(color, "badge-ghost") ].join(" ")
  end
end
