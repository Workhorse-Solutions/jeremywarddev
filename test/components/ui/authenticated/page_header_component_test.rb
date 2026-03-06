require "test_helper"

class UI::Authenticated::PageHeaderComponentTest < ViewComponent::TestCase
  def test_renders_title
    render_inline(UI::Authenticated::PageHeaderComponent.new(title: "My Page"))
    assert_selector "h1", text: "My Page"
  end

  def test_renders_description_when_provided
    render_inline(UI::Authenticated::PageHeaderComponent.new(title: "My Page", description: "Some info"))
    assert_selector "p", text: "Some info"
  end

  def test_omits_description_when_nil
    render_inline(UI::Authenticated::PageHeaderComponent.new(title: "My Page"))
    assert_no_selector "p"
  end

  def test_wrapper_has_mb_8_class
    result = render_inline(UI::Authenticated::PageHeaderComponent.new(title: "x"))
    assert_includes result.to_html, "mb-8"
  end

  def test_renders_actions_slot_when_provided
    render_inline(UI::Authenticated::PageHeaderComponent.new(title: "x")) do |header|
      header.with_actions { "<button>Go</button>".html_safe }
    end
    assert_selector "button", text: "Go"
  end

  def test_omits_actions_wrapper_when_no_slot
    render_inline(UI::Authenticated::PageHeaderComponent.new(title: "x"))
    assert_no_selector "[class*='flex-shrink-0']"
  end

  def test_omits_actions_wrapper_when_slot_renders_empty
    render_inline(UI::Authenticated::PageHeaderComponent.new(title: "x")) do |header|
      header.with_actions { "" }
    end

    assert_no_selector "[class*='flex-shrink-0']"
  end
end
