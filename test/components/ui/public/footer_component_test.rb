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

  def test_renders_footer_element
    render_inline(UI::Public::FooterComponent.new(copyright: "Acme Corp"))
    assert_selector "footer"
  end

  def test_renders_social_links_when_provided
    links = [
      UI::Public::SocialLinksComponent::Link.new(platform: :x, label: "@test", url: "https://x.com/test"),
      UI::Public::SocialLinksComponent::Link.new(platform: :linkedin, label: "in/test", url: "https://linkedin.com/in/test")
    ]
    render_inline(UI::Public::FooterComponent.new(copyright: "Acme Corp", social_links: links))
    assert_selector "a[href='https://x.com/test']"
    assert_selector "a[href='https://linkedin.com/in/test']"
    assert_selector "svg", minimum: 2
  end

  def test_omits_social_links_when_empty
    render_inline(UI::Public::FooterComponent.new(copyright: "Acme Corp"))
    assert_no_selector "a[target='_blank']"
  end
end
