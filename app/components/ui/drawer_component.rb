class UI::DrawerComponent < ViewComponent::Base
  def initialize(close_aria_label:, id: "menu-drawer", side_panel_class: "bg-base-100 min-h-full w-60 p-5")
    @id = id
    @side_panel_class = side_panel_class
    @close_aria_label = close_aria_label
  end

  private

  attr_reader :id, :side_panel_class, :close_aria_label
end
