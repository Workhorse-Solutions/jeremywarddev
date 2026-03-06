require "test_helper"

class UI::Public::FooterComponentTest < ViewComponent::TestCase
  def test_renders_copyright_text
    render_inline(UI::Public::FooterComponent.new(copyright: "Acme Corp"))
    assert_selector "footer", text: /Acme Corp/
  end

  def test_renders_current_year
    render_inline(UI::Public::FooterComponent.new(copyright: "Acme Corp"))
    assert_selector "footer", text: /#{Date.current.year}/
  end

  def test_has_expected_css_classes
    result = render_inline(UI::Public::FooterComponent.new(copyright: "Acme Corp"))
    assert_includes result.to_html, "footer-center"
    assert_includes result.to_html, "bg-base-200"
    assert_includes result.to_html, "text-base-content"
  end
end
