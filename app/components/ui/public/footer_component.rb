class UI::Public::FooterComponent < ViewComponent::Base
  def initialize(copyright:, social_links: [])
    @copyright = copyright
    @social_links = social_links
  end

  private

  attr_reader :copyright, :social_links
end
