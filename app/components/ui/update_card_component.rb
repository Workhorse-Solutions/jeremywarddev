class UI::UpdateCardComponent < ViewComponent::Base
  def initialize(date:, title:, description:)
    @date = date
    @title = title
    @description = description
  end

  private

  attr_reader :date, :title, :description
end
