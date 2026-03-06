class RailsFoundry::TabsComponent < ViewComponent::Base
  Tab = Struct.new(:label, :badge, keyword_init: true)

  renders_many :panels

  # @param tab_bar_frame [String, nil] Optional turbo frame ID to wrap the tab bar in.
  def initialize(tab_bar_frame: nil)
    @tab_bar_frame = tab_bar_frame
    @defined_tabs = []
  end

  # Add a tab to the tab bar.
  # @param label [String] The visible tab label (caller is responsible for i18n).
  # @param badge [Integer, nil] Optional badge count shown next to the label.
  # @param visible [Boolean] When false, the tab is not added (default: true).
  def with_tab(label:, badge: nil, visible: true)
    @defined_tabs << Tab.new(label: label, badge: badge) if visible
    self
  end

  # Ensure the render block is evaluated before the template runs so that
  # with_tab calls (which populate @defined_tabs) fire before the tab bar
  # is rendered. Slot-backed helpers (e.g. panels) trigger this lazily via
  # __vc_get_slot, but @defined_tabs is a plain ivar and has no such hook.
  def before_render
    content
  end

  private

  attr_reader :tab_bar_frame

  def tabs
    @defined_tabs
  end

  def wrap_tab_bar_in_frame?
    tab_bar_frame.present?
  end
end
