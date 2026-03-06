class UI::CtaPairComponent < ViewComponent::Base
  def initialize(
    primary_text:,
    primary_href:,
    secondary_text:,
    secondary_href:,
    variant: :default,
    justify: :start
  )
    @primary_text = primary_text
    @primary_href = primary_href
    @secondary_text = secondary_text
    @secondary_href = secondary_href
    @variant = variant
    @justify = justify
  end

  private

  attr_reader :primary_text, :primary_href, :secondary_text, :secondary_href, :variant, :justify

  def wrapper_class
    justify == :center ? "flex flex-wrap justify-center gap-4" : "flex flex-wrap gap-3"
  end

  def primary_class
    if variant == :inverted
      "btn btn-lg bg-white text-primary hover:bg-base-100 border-0"
    else
      "btn btn-primary btn-lg"
    end
  end

  def secondary_class
    if variant == :inverted
      "btn btn-lg btn-outline text-white border-white/40 hover:bg-white/10 hover:border-white/40"
    else
      "btn btn-outline btn-lg"
    end
  end
end
