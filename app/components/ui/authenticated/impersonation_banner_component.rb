class UI::Authenticated::ImpersonationBannerComponent < ViewComponent::Base
  def initialize(active:, message:, stop_label:, stop_href:)
    @active = active
    @message = message
    @stop_label = stop_label
    @stop_href = stop_href
  end

  def render?
    active
  end

  private

  attr_reader :active, :message, :stop_label, :stop_href
end
