require_relative "../application_system_test_case"

class Authenticated::InvitationsSystemTest < ApplicationSystemTestCase
  test "owner opens invite form and submits valid invitation" do
    sign_in_as users(:alice)
    visit team_path

    click_link I18n.t("authenticated.team.index.invite.heading")

    fill_in I18n.t("authenticated.invitations.new.email_label"), with: "invited@example.com"
    click_button I18n.t("authenticated.invitations.new.submit")

    assert_text I18n.t("authenticated.invitations.create.notice", email: "invited@example.com")
    assert_selector "[data-testid='pending-invitation-row']", visible: :all
    assert_text "invited@example.com"
  end

  test "owner sees inline error when inviting duplicate email" do
    sign_in_as users(:alice)
    visit team_path

    click_link I18n.t("authenticated.team.index.invite.heading")

    fill_in I18n.t("authenticated.invitations.new.email_label"), with: users(:member_carol).email
    click_button I18n.t("authenticated.invitations.new.submit")

    assert_selector "p", text: /already a member/
  end

  test "member does not see invite button" do
    sign_in_as users(:member_carol)
    visit team_path

    assert_no_selector "a[href='#{new_team_invitation_path}']"
  end
end
