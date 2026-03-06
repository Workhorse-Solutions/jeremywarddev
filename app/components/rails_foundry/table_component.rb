class RailsFoundry::TableComponent < ViewComponent::Base
  def initialize(id: nil, caption: nil, pagy: nil)
    @frame_id = id
    @caption = caption
    @pagy = pagy
  end

  private

  attr_reader :frame_id, :caption, :pagy

  def show_pagination?
    pagy.present? && pagy.pages > 1
  end
end
