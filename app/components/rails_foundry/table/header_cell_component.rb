class RailsFoundry::Table::HeaderCellComponent < ViewComponent::Base
  def initialize(label:, sort_key: nil, visible: true)
    @label = label
    @sort_key = sort_key
    @visible = visible
  end

  def render?
    @visible
  end

  private

  attr_reader :label, :sort_key

  def sort_active?
    helpers.params[:sort].to_s == sort_key.to_s
  end

  def current_direction
    helpers.params[:direction].to_s.presence || "asc"
  end

  def next_direction
    sort_active? && current_direction == "asc" ? "desc" : "asc"
  end

  def sort_indicator
    return nil unless sort_key && sort_active?

    current_direction == "asc" ? "▲" : "▼"
  end

  def sort_url
    helpers.url_for(
      helpers.request.query_parameters.merge(
        "sort" => sort_key.to_s,
        "direction" => next_direction
      )
    )
  end
end
