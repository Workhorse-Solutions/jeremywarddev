class UI::PricingCardComponent < ViewComponent::Base
  def initialize(name:, price:, tagline:, cta_text:, cta_href:, features:, highlighted: false, badge: nil)
    @name = name
    @price = price
    @tagline = tagline
    @cta_text = cta_text
    @cta_href = cta_href
    @features = features
    @highlighted = highlighted
    @badge = badge
  end

  private

  attr_reader :name, :price, :tagline, :cta_text, :cta_href, :features, :highlighted, :badge
end
