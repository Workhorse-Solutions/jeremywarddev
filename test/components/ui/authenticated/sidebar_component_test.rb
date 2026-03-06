require "test_helper"

class UI::Authenticated::SidebarComponentTest < ViewComponent::TestCase
  def default_nav_sections
    [
      {
        label: "Main",
        items: [
          { label: "Dashboard", href: "/dashboard", icon: "home" }
        ]
      },
      {
        label: "Account",
        items: [
          { label: "Team", href: "/team", icon: "user-group" }
        ]
      }
    ]
  end

  def test_renders_aside_element
    render_inline(UI::Authenticated::SidebarComponent.new(
      brand_label: "MyApp",
      brand_href: "/dashboard",
      nav_sections: default_nav_sections
    ))
    assert_selector "aside"
  end

  def test_renders_brand_link
    render_inline(UI::Authenticated::SidebarComponent.new(
      brand_label: "MyApp",
      brand_href: "/dashboard",
      nav_sections: default_nav_sections
    ))
    assert_selector "a[href='/dashboard']", text: "MyApp"
  end

  def test_renders_section_labels
    render_inline(UI::Authenticated::SidebarComponent.new(
      brand_label: "MyApp",
      brand_href: "/dashboard",
      nav_sections: default_nav_sections
    ))
    assert_selector "[data-testid='nav-section-label']", count: 2
    assert_selector ".menu-title", text: "Main"
    assert_selector ".menu-title", text: "Account"
  end

  def test_renders_nav_items_within_sections
    render_inline(UI::Authenticated::SidebarComponent.new(
      brand_label: "MyApp",
      brand_href: "/dashboard",
      nav_sections: default_nav_sections
    ))
    assert_selector "a[href='/dashboard']", text: "Dashboard"
    assert_selector "a[href='/team']", text: "Team"
  end

  def test_renders_nav_item_icons
    render_inline(UI::Authenticated::SidebarComponent.new(
      brand_label: "MyApp",
      brand_href: "/dashboard",
      nav_sections: default_nav_sections
    ))
    assert_selector "ul.menu li svg", count: 2
  end
end
