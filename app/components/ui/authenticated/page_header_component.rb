class UI::Authenticated::PageHeaderComponent < ViewComponent::Base
  renders_one :actions

  def initialize(title:, description: nil)
    @title = title
    @description = description
  end

  private

  attr_reader :title, :description
end
