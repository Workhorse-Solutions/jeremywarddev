require "test_helper"

class RailsFoundry::TabsComponentTest < ViewComponent::TestCase
  def build_component(**kwargs, &block)
    render_inline(RailsFoundry::TabsComponent.new(**kwargs), &block)
  end

  # Renders the stimulus controller wrapper
  def test_renders_stimulus_controller
    build_component do |c|
      c.with_tab(label: "Tab A")
      c.with_panel { "Panel A" }
    end

    assert_selector "[data-controller='tabs']"
  end

  # Renders tab buttons with correct data attributes
  def test_renders_tab_buttons
    build_component do |c|
      c.with_tab(label: "Members")
      c.with_tab(label: "Invitations")
      c.with_panel { "Members content" }
      c.with_panel { "Invitations content" }
    end

    assert_selector "button[role='tab']", count: 2
    assert_selector "button[data-tabs-index-param='0']", text: "Members"
    assert_selector "button[data-tabs-index-param='1']", text: "Invitations"
  end

  # First tab starts active, subsequent tabs start inactive
  def test_first_tab_is_active_others_inactive
    result = build_component do |c|
      c.with_tab(label: "A")
      c.with_tab(label: "B")
      c.with_panel { "A" }
      c.with_panel { "B" }
    end

    first_tab = page.all("button[role='tab']").first
    assert_includes first_tab[:class], "tab-active"

    second_tab = page.all("button[role='tab']").last
    assert_includes result.to_html, "text-base-content/60"
    refute_includes second_tab[:class], "tab-active"
  end

  # Second+ panels start hidden
  def test_panels_hidden_except_first
    build_component do |c|
      c.with_tab(label: "A")
      c.with_tab(label: "B")
      c.with_panel { "Panel A" }
      c.with_panel { "Panel B" }
    end

    panels = page.all("[data-tabs-target='panel']")
    assert_equal 2, panels.size
    refute_includes panels[0][:class].to_s, "hidden"
    assert_includes panels[1][:class], "hidden"
  end

  # Badge renders when provided
  def test_renders_badge_when_provided
    build_component do |c|
      c.with_tab(label: "Invitations", badge: 3)
      c.with_panel { "content" }
    end

    assert_selector "span.badge", text: "3"
  end

  # No badge rendered when badge is nil
  def test_no_badge_when_nil
    build_component do |c|
      c.with_tab(label: "Members")
      c.with_panel { "content" }
    end

    assert_no_selector "span.badge"
  end

  # Tab with visible: false is not rendered
  def test_tab_with_visible_false_is_omitted
    build_component do |c|
      c.with_tab(label: "Members")
      c.with_tab(label: "Hidden", visible: false)
      c.with_panel { "Members content" }
    end

    assert_selector "button[role='tab']", count: 1
    assert_no_selector "button[role='tab']", text: "Hidden"
  end

  # Without tab_bar_frame, no turbo frame wraps the tab bar
  def test_no_turbo_frame_by_default
    build_component do |c|
      c.with_tab(label: "Tab")
      c.with_panel { "content" }
    end

    assert_no_selector "turbo-frame"
  end

  # With tab_bar_frame, tab bar is wrapped in a turbo frame
  def test_turbo_frame_wraps_tab_bar_when_given
    with_request_url "/" do
      build_component(tab_bar_frame: "my-tab-bar") do |c|
        c.with_tab(label: "Tab")
        c.with_panel { "content" }
      end
    end

    assert_selector "turbo-frame#my-tab-bar [role='tablist']"
  end
end
