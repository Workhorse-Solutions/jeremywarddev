require "test_helper"

class UI::NavListComponentTest < ViewComponent::TestCase
  def test_renders_nav_items
    items = [ { label: "Home", href: "/" }, { label: "About", href: "/about" } ]
    render_inline(UI::NavListComponent.new(items: items))
    assert_selector "ul li", count: 2
    assert_selector "li a[href='/']", text: "Home"
    assert_selector "li a[href='/about']", text: "About"
  end

  def test_horizontal_orientation_default_class
    render_inline(UI::NavListComponent.new(items: []))
    assert_selector "ul.menu.menu-horizontal"
  end

  def test_vertical_orientation_class
    result = render_inline(UI::NavListComponent.new(items: [], orientation: :vertical))
    assert_includes result.to_html, "w-full"
  end

  def test_custom_ul_class_overrides_default
    render_inline(UI::NavListComponent.new(items: [], ul_class: "my-custom-class"))
    assert_selector "ul.my-custom-class"
  end

  def test_li_class_applied_to_items
    items = [ { label: "Link", href: "/" } ]
    render_inline(UI::NavListComponent.new(items: items, li_class: "custom-li"))
    assert_selector "li.custom-li"
  end

  def test_active_item_has_aria_current
    items = [ { label: "Home", href: "/" }, { label: "About", href: "/about" } ]
    render_inline(UI::NavListComponent.new(items: items, current_href: "/"))
    assert_selector "a[href='/'][aria-current='page']", text: "Home"
    assert_no_selector "a[href='/about'][aria-current]"
  end

  def test_active_item_has_active_class
    items = [ { label: "Home", href: "/" }, { label: "About", href: "/about" } ]
    render_inline(UI::NavListComponent.new(items: items, current_href: "/"))
    assert_selector "a.active[href='/']", text: "Home"
    assert_no_selector "a.active[href='/about']"
  end

  def test_no_active_items_when_current_href_nil
    items = [ { label: "Home", href: "/" } ]
    render_inline(UI::NavListComponent.new(items: items))
    assert_no_selector "a[aria-current]"
    assert_no_selector "a.active"
  end
end
