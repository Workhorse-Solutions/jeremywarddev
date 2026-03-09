class UI::Public::HeroComponent < ViewComponent::Base
  SIZES = %i[large compact].freeze

  def initialize(title:, subtitle: nil, size: :large, cta_label: nil, cta_href: nil)
    @title = title
    @subtitle = subtitle
    @size = SIZES.include?(size) ? size : :large
    @cta_label = cta_label
    @cta_href = cta_href
  end

  private

  attr_reader :title, :subtitle, :size, :cta_label, :cta_href

  def large?
    size == :large
  end

  def show_cta?
    large? && cta_label.present? && cta_href.present?
  end
end
