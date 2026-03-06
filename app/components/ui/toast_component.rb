class UI::ToastComponent < ViewComponent::Base
  def initialize(message:, type: :notice, timeout_ms: 5000, close_label: "Close")
    @message = message
    @type = type.to_s
    @timeout_ms = timeout_ms
    @close_label = close_label
  end

  private

  attr_reader :message, :type, :timeout_ms, :close_label

  def alert_class
    case type
    when "notice", "success"
      "alert-success"
    when "alert", "error"
      "alert-error"
    when "warning"
      "alert-warning"
    else
      "alert-info"
    end
  end
end
