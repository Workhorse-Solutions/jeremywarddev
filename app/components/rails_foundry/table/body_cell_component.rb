class RailsFoundry::Table::BodyCellComponent < ViewComponent::Base
  def initialize(visible: true)
    @visible = visible
  end

  def render?
    @visible
  end
end
