require "test_helper"

class RailsFoundry::Table::HeaderCellComponentTest < ViewComponent::TestCase
  # Renders label inside a th element
  def test_renders_label_in_th
    with_request_url "/team" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name"))
    end

    assert_selector "th", text: "Name"
  end

  # Renders a sort link when sort_key is given
  def test_renders_sort_link_when_sort_key_given
    with_request_url "/team" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name", sort_key: :name))
    end

    assert_selector "th a[href*='sort=name'][href*='direction=asc']", text: "Name"
  end

  # No link rendered when sort_key is absent
  def test_no_sort_link_without_sort_key
    with_request_url "/team" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name"))
    end

    assert_no_selector "th a"
    assert_selector "th", text: "Name"
  end

  # Active ascending column shows up indicator
  def test_active_ascending_shows_up_indicator
    with_request_url "/team?sort=name&direction=asc" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name", sort_key: :name))
    end

    assert_selector "th a span", text: "▲"
  end

  # Active descending column shows down indicator
  def test_active_descending_shows_down_indicator
    with_request_url "/team?sort=name&direction=desc" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name", sort_key: :name))
    end

    assert_selector "th a span", text: "▼"
  end

  # Active asc column link toggles to desc
  def test_active_asc_column_links_to_desc
    with_request_url "/team?sort=name&direction=asc" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name", sort_key: :name))
    end

    assert_selector "a[href*='sort=name'][href*='direction=desc']"
  end

  # Active desc column link toggles to asc
  def test_active_desc_column_links_to_asc
    with_request_url "/team?sort=name&direction=desc" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name", sort_key: :name))
    end

    assert_selector "a[href*='sort=name'][href*='direction=asc']"
  end

  # Inactive sortable column shows no indicator
  def test_inactive_sortable_column_shows_no_indicator
    with_request_url "/team?sort=email&direction=asc" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Name", sort_key: :name))
    end

    assert_no_selector "th a span"
    assert_selector "th a", text: "Name"
  end

  # visible: false renders nothing
  def test_visible_false_renders_nothing
    with_request_url "/team" do
      render_inline(RailsFoundry::Table::HeaderCellComponent.new(label: "Actions", visible: false))
    end

    assert_no_selector "th"
  end
end
