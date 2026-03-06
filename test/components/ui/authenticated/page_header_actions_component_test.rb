require "test_helper"

class UI::Authenticated::PageHeaderActionsComponentTest < ViewComponent::TestCase
  def test_renders_link_when_can_manage
    render_inline(UI::Authenticated::PageHeaderActionsComponent.new(
      can_manage: true,
      label: "Invite Member",
      href: "/invitations/new"
    ))

    assert_selector "a", text: "Invite Member"
    assert_selector "a[href='/invitations/new']"
  end

  def test_renders_nothing_when_cannot_manage
    render_inline(UI::Authenticated::PageHeaderActionsComponent.new(
      can_manage: false,
      label: "Invite Member",
      href: "/invitations/new"
    ))

    assert_no_selector "a"
  end

  def test_renders_link_with_button_classes
    render_inline(UI::Authenticated::PageHeaderActionsComponent.new(
      can_manage: true,
      label: "Invite Member",
      href: "/invitations/new"
    ))

    assert_selector "a.btn.btn-primary.btn-sm"
  end

  def test_sets_turbo_frame_data_attribute_when_provided
    render_inline(UI::Authenticated::PageHeaderActionsComponent.new(
      can_manage: true,
      label: "Invite Member",
      href: "/invitations/new",
      turbo_frame: "modal"
    ))

    assert_selector "a[data-turbo-frame='modal']"
  end

  def test_omits_turbo_frame_attribute_when_not_provided
    render_inline(UI::Authenticated::PageHeaderActionsComponent.new(
      can_manage: true,
      label: "Invite Member",
      href: "/invitations/new"
    ))

    assert_no_selector "a[data-turbo-frame]"
  end
end
