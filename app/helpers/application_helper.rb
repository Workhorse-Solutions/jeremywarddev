module ApplicationHelper
  ROLE_BADGE_COLORS = {
    "owner" => :primary,
    "admin" => :secondary
  }.freeze

  def badge_color_for(role)
    ROLE_BADGE_COLORS.fetch(role, :ghost)
  end
end
