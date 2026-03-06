class UI::SplitLayoutComponent < ViewComponent::Base
  renders_one :text_column
  renders_one :visual_column

  def initialize(reversed: false, hide_visual_on_mobile: false)
    @reversed = reversed
    @hide_visual_on_mobile = hide_visual_on_mobile
  end

  private

  attr_reader :reversed, :hide_visual_on_mobile

  def visual_wrapper_class
    hide_visual_on_mobile ? "hidden lg:flex items-center justify-center" : ""
  end
end
