class UI::NavListComponent < ViewComponent::Base
  def initialize(items:, orientation: :horizontal, ul_class: nil, li_class: "font-medium", current_href: nil)
    @items = items
    @orientation = orientation
    @ul_class = ul_class || default_ul_class
    @li_class = li_class
    @current_href = current_href
  end

  private

  attr_reader :items, :orientation, :ul_class, :li_class, :current_href

  def active?(item)
    current_href.present? && item[:href] == current_href
  end

  def default_ul_class
    orientation == :vertical ? "menu w-full gap-2 p-0 pt-4" : "menu menu-horizontal gap-2 px-1"
  end
end
