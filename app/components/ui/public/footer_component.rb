class UI::Public::FooterComponent < ViewComponent::Base
  def initialize(copyright:)
    @copyright = copyright
  end

  private

  attr_reader :copyright
end
