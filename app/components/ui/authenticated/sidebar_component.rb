class UI::Authenticated::SidebarComponent < ViewComponent::Base
  def initialize(brand_label:, brand_href:, nav_sections:)
    @brand_label = brand_label
    @brand_href = brand_href
    @nav_sections = nav_sections
  end

  private

  attr_reader :brand_label, :brand_href, :nav_sections
end
