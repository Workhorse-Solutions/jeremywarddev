class UI::Authenticated::PageHeaderActionsComponent < ViewComponent::Base
  def initialize(can_manage:, label:, href:, turbo_frame: nil)
    @can_manage = can_manage
    @label = label
    @href = href
    @turbo_frame = turbo_frame
  end

  def render?
    @can_manage
  end

  private

  attr_reader :can_manage, :label, :href, :turbo_frame
end
