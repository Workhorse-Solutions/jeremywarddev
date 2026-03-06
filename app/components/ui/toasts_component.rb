class UI::ToastsComponent < ViewComponent::Base
  def initialize(flash:, timeout_ms: 5000, close_label: "Close")
    @flash = flash
    @timeout_ms = timeout_ms
    @close_label = close_label
  end

  def render?
    entries.any?
  end

  private

  attr_reader :flash, :timeout_ms, :close_label

  def entries
    @entries ||= flash.to_hash.filter_map do |type, message|
      next if message.blank?
      [ type, message ]
    end
  end
end
