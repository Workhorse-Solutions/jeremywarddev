require "test_helper"

class UI::DrawerComponentTest < ViewComponent::TestCase
  def test_renders_drawer_structure
    render_inline(UI::DrawerComponent.new(close_aria_label: "Close sidebar"))
    assert_selector "div.drawer"
    assert_selector "input.drawer-toggle"
    assert_selector "label.drawer-overlay"
  end

  def test_uses_default_id
    render_inline(UI::DrawerComponent.new(close_aria_label: "Close"))
    assert_selector "input#menu-drawer"
    assert_selector "label[for='menu-drawer']"
  end

  def test_uses_custom_id
    render_inline(UI::DrawerComponent.new(id: "custom-drawer", close_aria_label: "Close"))
    assert_selector "input#custom-drawer"
    assert_selector "label[for='custom-drawer']"
  end

  def test_close_aria_label_on_overlay
    render_inline(UI::DrawerComponent.new(close_aria_label: "Close sidebar"))
    assert_selector "label.drawer-overlay[aria-label='Close sidebar']"
  end

  def test_renders_yielded_content
    result = render_inline(UI::DrawerComponent.new(close_aria_label: "Close").with_content("<p>Side content</p>"))
    assert_includes result.to_html, "Side content"
  end

  def test_toggle_has_drawer_target
    render_inline(UI::DrawerComponent.new(close_aria_label: "Close"))
    assert_selector "input.drawer-toggle[data-drawer-target='toggle']"
  end
end
