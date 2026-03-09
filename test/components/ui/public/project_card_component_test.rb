require "test_helper"

class UI::Public::ProjectCardComponentTest < ViewComponent::TestCase
  def test_renders_project_name_as_heading
    render_inline(UI::Public::ProjectCardComponent.new(
      name: "RailsFoundry",
      description: "A SaaS starter kit.",
      tags: [ "Rails 8", "Kamal" ]
    ))
    assert_selector "h3.card-title", text: "RailsFoundry"
  end

  def test_renders_description
    render_inline(UI::Public::ProjectCardComponent.new(
      name: "RailsFoundry",
      description: "A SaaS starter kit.",
      tags: []
    ))
    assert_text "A SaaS starter kit."
  end

  def test_renders_tags_as_badges
    render_inline(UI::Public::ProjectCardComponent.new(
      name: "RailsFoundry",
      description: "A SaaS starter kit.",
      tags: [ "Rails 8", "Kamal", "DaisyUI" ]
    ))
    assert_selector ".badge", count: 3
    assert_selector ".badge", text: "Rails 8"
    assert_selector ".badge", text: "Kamal"
    assert_selector ".badge", text: "DaisyUI"
  end

  def test_renders_link_when_url_provided
    render_inline(UI::Public::ProjectCardComponent.new(
      name: "RailsFoundry",
      description: "A SaaS starter kit.",
      tags: [],
      url: "https://railsfoundry.com"
    ))
    assert_selector "a[href='https://railsfoundry.com'][target='_blank'][rel='noopener noreferrer']"
  end

  def test_omits_link_when_no_url
    render_inline(UI::Public::ProjectCardComponent.new(
      name: "RailsFoundry",
      description: "A SaaS starter kit.",
      tags: []
    ))
    assert_no_selector ".card-actions"
  end

  def test_wraps_in_card_component
    render_inline(UI::Public::ProjectCardComponent.new(
      name: "RailsFoundry",
      description: "A SaaS starter kit.",
      tags: []
    ))
    assert_selector ".card .card-body"
  end
end
