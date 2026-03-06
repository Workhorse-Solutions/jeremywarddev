class UI::CardGridComponent < ViewComponent::Base
  def initialize(cols: 3, wrapper_class: nil)
    @cols = cols
    @wrapper_class = wrapper_class
  end

  private

  attr_reader :cols, :wrapper_class

  def grid_class
    col_classes = case cols
    when 2 then "grid-cols-1 md:grid-cols-2"
    when 4 then "grid-cols-1 md:grid-cols-2 lg:grid-cols-4"
    else "grid-cols-1 md:grid-cols-2 lg:grid-cols-3"
    end
    [ "grid gap-6", col_classes, wrapper_class ].compact.join(" ")
  end
end
