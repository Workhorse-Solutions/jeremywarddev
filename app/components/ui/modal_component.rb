class UI::ModalComponent < ViewComponent::Base
  renders_one :footer

  def initialize(title:, size: :md, open: true, close_label: "Close", id: nil, title_data: {})
    @title = title
    @size = size
    @open = open
    @close_label = close_label
    @id = id
    @title_data = title_data
  end

  private

  attr_reader :title, :size, :open, :close_label, :id, :title_data

  def as_dialog?
    id.present?
  end

  def modal_classes
    classes = [ "modal" ]
    classes << "modal-open" if open
    classes.join(" ")
  end

  def size_class
    case size
    when :sm
      "max-w-lg"
    when :lg
      "max-w-4xl"
    else
      "max-w-3xl"
    end
  end

  def title_id
    "modal-title-#{object_id}"
  end

  def title_tag_options
    { id: title_id, class: "font-bold text-lg pr-10", data: title_data }
  end
end
