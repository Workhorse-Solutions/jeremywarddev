class UI::Authenticated::TopBarComponent < ViewComponent::Base
  renders_one :greeting
  renders_one :user_dropdown

  def initialize(mobile_menu_aria_label:)
    @mobile_menu_aria_label = mobile_menu_aria_label
  end

  private

  attr_reader :mobile_menu_aria_label
end
