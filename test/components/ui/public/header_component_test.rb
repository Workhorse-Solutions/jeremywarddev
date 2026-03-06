require "test_helper"

class UI::Public::HeaderComponentTest < ViewComponent::TestCase
  def default_component
    UI::Public::HeaderComponent.new(
      brand: { label: "MyApp", href: "/" },
      nav_items: [
        { label: "Features", href: "#features" },
        { label: "Pricing", href: "#pricing" }
      ],
      ctas: [
        { label: "Sign In", href: "/login", css_class: "btn btn-primary btn-sm" }
      ],
      open_drawer_aria_label: "Open sidebar",
      close_drawer_aria_label: "Close sidebar"
    )
  end

  def test_renders_header_element
    render_inline(default_component)
    assert_selector "header"
  end

  def test_renders_brand_link
    render_inline(default_component)
    assert_selector "a[href='/']", text: "MyApp"
  end

  def test_renders_desktop_nav_items
    render_inline(default_component)
    assert_selector "a[href='#features']", text: "Features"
    assert_selector "a[href='#pricing']", text: "Pricing"
  end

  def test_renders_cta_links
    render_inline(default_component)
    assert_selector "a.btn.btn-primary.btn-sm[href='/login']", text: "Sign In"
  end

  def test_renders_multiple_ctas
    component = UI::Public::HeaderComponent.new(
      brand: { label: "MyApp", href: "/" },
      nav_items: [],
      ctas: [
        { label: "Get Started", href: "/start", css_class: "btn btn-ghost btn-sm" },
        { label: "Sign In", href: "/login", css_class: "btn btn-primary btn-sm" }
      ],
      open_drawer_aria_label: "Open sidebar",
      close_drawer_aria_label: "Close sidebar"
    )
    render_inline(component)
    assert_selector "a.btn", count: 2
    assert_selector "a.btn-ghost", text: "Get Started"
    assert_selector "a.btn-primary", text: "Sign In"
  end

  def test_hamburger_trigger_aria_label
    render_inline(default_component)
    assert_selector "label[aria-label='Open sidebar']"
  end

  def test_hamburger_trigger_has_aria_expanded
    render_inline(default_component)
    assert_selector "label[aria-expanded='false']"
  end

  def test_renders_drawer_with_mobile_nav
    render_inline(default_component)
    assert_selector "div.drawer"
  end

  def test_mobile_nav_items_default_to_nav_items
    render_inline(default_component)
    # Brand link appears in header AND drawer (2 occurrences)
    assert_selector "a[href='/']", text: "MyApp", count: 2
  end

  def test_custom_mobile_nav_items
    component = UI::Public::HeaderComponent.new(
      brand: { label: "MyApp", href: "/" },
      nav_items: [
        { label: "Features", href: "#features" }
      ],
      mobile_nav_items: [
        { label: "Home", href: "/" },
        { label: "Features", href: "#features" },
        { label: "About", href: "/about" }
      ],
      ctas: [
        { label: "Sign In", href: "/login", css_class: "btn btn-primary btn-sm" }
      ],
      open_drawer_aria_label: "Open sidebar",
      close_drawer_aria_label: "Close sidebar"
    )
    render_inline(component)
    # Desktop nav has only 1 item
    assert_selector ".max-lg\\:hidden a", count: 1
    # Drawer has the 3 mobile-specific items
    assert_selector ".drawer a[href='/about']", text: "About"
  end

  def test_custom_drawer_id
    component = UI::Public::HeaderComponent.new(
      brand: { label: "MyApp", href: "/" },
      nav_items: [],
      ctas: [],
      drawer_id: "custom-drawer",
      open_drawer_aria_label: "Open sidebar",
      close_drawer_aria_label: "Close sidebar"
    )
    render_inline(component)
    assert_selector "label[for='custom-drawer']"
    assert_selector "input#custom-drawer"
  end

  def test_header_has_scroll_spy_controller
    render_inline(default_component)
    assert_selector "header[data-controller='scroll-spy']"
  end

  def test_drawer_container_has_drawer_controller
    render_inline(default_component)
    assert_selector "[data-controller='drawer']"
  end
end
