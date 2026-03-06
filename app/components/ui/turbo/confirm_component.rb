class UI::Turbo::ConfirmComponent < ViewComponent::Base
  def initialize(confirm_label:, cancel_label:)
    @confirm_label = confirm_label
    @cancel_label = cancel_label
  end

  private

  attr_reader :confirm_label, :cancel_label
end
