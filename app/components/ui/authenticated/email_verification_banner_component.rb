class UI::Authenticated::EmailVerificationBannerComponent < ViewComponent::Base
  def initialize(verified:)
    @verified = verified
  end

  def render?
    !verified
  end

  private

  attr_reader :verified
end
