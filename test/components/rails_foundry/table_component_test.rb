require "test_helper"

class RailsFoundry::TableComponentTest < ViewComponent::TestCase
  PagyStub = Struct.new(:pages, :nav_html, keyword_init: true) do
    def series_nav
      nav_html
    end
  end

  def stub_pagy(pages:, nav: "<nav class='pagy'>nav</nav>")
    PagyStub.new(pages: pages, nav_html: nav)
  end

  def table_content
    "<thead><tr><th>Name</th></tr></thead><tbody><tr><td>Alice</td></tr></tbody>".html_safe
  end

  # Yielded content renders inside the table element
  def test_renders_yielded_content_inside_table
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new.with_content(table_content))
    end

    assert_selector "table th", text: "Name"
    assert_selector "table td", text: "Alice"
  end

  # id argument wraps output in turbo frame
  def test_id_argument_wraps_output_in_turbo_frame
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new(id: "team-members").with_content(table_content))
    end

    assert_selector "turbo-frame#team-members table"
  end

  # Without id, no turbo frame wrapper
  def test_no_id_emits_no_turbo_frame_wrapper
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new.with_content(table_content))
    end

    assert_no_selector "turbo-frame"
  end

  # caption argument renders a caption element
  def test_caption_renders_caption_element
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new(caption: "Team Members").with_content(table_content))
    end

    assert_selector "caption", text: "Team Members"
  end

  # No caption element without caption argument
  def test_no_caption_without_argument
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new.with_content(table_content))
    end

    assert_no_selector "caption"
  end

  # Pagination renders when pagy.pages > 1
  def test_pagination_renders_when_multiple_pages
    pagy = stub_pagy(pages: 4)
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new(pagy: pagy).with_content(table_content))
    end

    assert_selector "nav.pagy"
  end

  # Pagination absent when single page
  def test_pagination_absent_when_single_page
    pagy = stub_pagy(pages: 1, nav: "")
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new(pagy: pagy).with_content(table_content))
    end

    assert_no_selector "nav.pagy"
  end

  # No pagination without pagy
  def test_no_pagination_without_pagy
    with_request_url "/team" do
      render_inline(RailsFoundry::TableComponent.new.with_content(table_content))
    end

    assert_no_selector "nav"
  end
end
