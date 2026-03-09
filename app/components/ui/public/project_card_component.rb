class UI::Public::ProjectCardComponent < ViewComponent::Base
  def initialize(name:, description:, tags:, url: nil)
    @name = name
    @description = description
    @tags = Array(tags)
    @url = url
  end

  private

  attr_reader :name, :description, :tags, :url
end
