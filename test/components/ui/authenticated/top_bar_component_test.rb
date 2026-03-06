require "test_helper"

class UI::Authenticated::TopBarComponentTest < ViewComponent::TestCase
  def test_renders_header_element
    render_inline(UI::Authenticated::TopBarComponent.new(
      mobile_menu_aria_label: "Open menu"
    ))
    assert_selector "header"
  end

  def test_renders_mobile_menu_button_with_aria_label
    render_inline(UI::Authenticated::TopBarComponent.new(
      mobile_menu_aria_label: "Open menu"
    ))
    assert_selector "button[aria-label='Open menu']"
  end

  def test_renders_greeting_slot
    render_inline(UI::Authenticated::TopBarComponent.new(
      mobile_menu_aria_label: "Open menu"
    )) do |c|
      c.with_greeting { "Hello there" }
    end
    assert_text "Hello there"
  end

  def test_renders_user_dropdown_slot
    render_inline(UI::Authenticated::TopBarComponent.new(
      mobile_menu_aria_label: "Open menu"
    )) do |c|
      c.with_user_dropdown { "Dropdown content" }
    end
    assert_text "Dropdown content"
  end
end
