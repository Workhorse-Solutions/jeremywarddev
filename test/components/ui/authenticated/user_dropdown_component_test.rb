require "test_helper"

class UI::Authenticated::UserDropdownComponentTest < ViewComponent::TestCase
  def default_component
    UI::Authenticated::UserDropdownComponent.new(
      user_full_name: "Alice Smith",
      user_email: "alice@example.com",
      user_initials: "AS",
      menu_items: [
        { label: "Dashboard", href: "/dashboard", icon: "home" },
        { label: "Pricing", href: "/pricing", icon: "credit-card" }
      ],
      sign_out_label: "Sign Out",
      sign_out_href: "/logout"
    )
  end

  def test_renders_dropdown
    render_inline(default_component)
    assert_selector ".dropdown.dropdown-end"
  end

  def test_renders_user_initials
    render_inline(default_component)
    assert_selector ".avatar span", text: "AS"
  end

  def test_renders_user_full_name
    render_inline(default_component)
    assert_selector "p", text: "Alice Smith"
  end

  def test_renders_user_email
    render_inline(default_component)
    assert_selector "p", text: "alice@example.com"
  end

  def test_renders_menu_items
    render_inline(default_component)
    assert_selector "ul.menu li a[href='/dashboard']", text: "Dashboard"
    assert_selector "ul.menu li a[href='/pricing']", text: "Pricing"
  end

  def test_renders_sign_out_link
    render_inline(default_component)
    assert_selector "a.text-error[href='/logout']", text: "Sign Out"
  end

  def test_renders_divider_before_sign_out
    render_inline(default_component)
    assert_selector ".divider"
  end
end
