class UI::Public::HeaderComponent < ViewComponent::Base
  def initialize(brand:, nav_items:, ctas:, open_drawer_aria_label:, close_drawer_aria_label:,
                 mobile_nav_items: nil, drawer_id: "menu-drawer")
    @brand = brand
    @nav_items = nav_items
    @mobile_nav_items = mobile_nav_items || nav_items
    @ctas = ctas
    @drawer_id = drawer_id
    @open_drawer_aria_label = open_drawer_aria_label
    @close_drawer_aria_label = close_drawer_aria_label
  end

  private

  attr_reader :brand, :nav_items, :mobile_nav_items, :ctas, :drawer_id,
              :open_drawer_aria_label, :close_drawer_aria_label

  def brand_link
    helpers.link_to brand[:label], brand[:href], class: "text-xl font-bold text-primary"
  end
end
