class UI::SectionHeaderComponent < ViewComponent::Base
  DEFAULT_LABEL_CLASS = "text-primary font-semibold uppercase tracking-wider text-sm mb-4"
  DEFAULT_HEADING_CLASS = "text-4xl font-bold mb-4"

  def initialize(
    heading:,
    tag: :h2,
    label: nil,
    subheading: nil,
    align: :center,
    label_class: DEFAULT_LABEL_CLASS,
    heading_class: DEFAULT_HEADING_CLASS
  )
    @heading = heading
    @tag = tag
    @label = label
    @subheading = subheading
    @align = align
    @label_class = label_class
    @heading_class = heading_class
  end

  private

  attr_reader :heading, :tag, :label, :subheading, :align, :label_class, :heading_class

  def wrapper_class
    align == :center ? "text-center mb-14" : "mb-14"
  end

  def subheading_class
    align == :center ? "text-lg text-base-content/60 max-w-2xl mx-auto" : "text-lg text-base-content/60"
  end
end
