require "test_helper"

class UI::Public::SocialLinksComponentTest < ViewComponent::TestCase
  def setup
    @links = [
      UI::Public::SocialLinksComponent::Link.new(platform: :x, label: "@jeremywarddev", url: "https://x.com/jeremywarddev"),
      UI::Public::SocialLinksComponent::Link.new(platform: :linkedin, label: "in/jrmyward", url: "https://linkedin.com/in/jrmyward"),
      UI::Public::SocialLinksComponent::Link.new(platform: :youtube, label: "@jeremywarddev", url: "https://youtube.com/@jeremywarddev")
    ]
  end

  def test_full_variant_renders_labels_with_icons
    render_inline(UI::Public::SocialLinksComponent.new(links: @links, variant: :full))
    assert_selector "ul"
    assert_selector "li", count: 3
    assert_selector "a span", text: "@jeremywarddev"
    assert_selector "a span", text: "in/jrmyward"
    assert_selector "svg", count: 3
  end

  def test_compact_variant_renders_icon_only_links
    render_inline(UI::Public::SocialLinksComponent.new(links: @links, variant: :compact))
    assert_no_selector "ul"
    assert_selector "div.flex"
    assert_selector "a svg", count: 3
    assert_no_selector "span"
  end

  def test_links_open_in_new_tab
    render_inline(UI::Public::SocialLinksComponent.new(links: @links, variant: :full))
    assert_selector "a[target='_blank']", count: 3
    assert_selector "a[rel='noopener noreferrer']", count: 3
  end

  def test_compact_variant_links_have_aria_labels
    render_inline(UI::Public::SocialLinksComponent.new(links: @links, variant: :compact))
    assert_selector "a[aria-label='@jeremywarddev']"
    assert_selector "a[aria-label='in/jrmyward']"
  end

  def test_full_variant_renders_all_three_platforms
    render_inline(UI::Public::SocialLinksComponent.new(links: @links, variant: :full))
    assert_selector "a[href='https://x.com/jeremywarddev']"
    assert_selector "a[href='https://linkedin.com/in/jrmyward']"
    assert_selector "a[href='https://youtube.com/@jeremywarddev']"
  end
end
