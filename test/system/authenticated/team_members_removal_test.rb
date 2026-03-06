require_relative "../application_system_test_case"

class Authenticated::TeamMembersRemovalSystemTest < ApplicationSystemTestCase
  test "owner removes a member and sees success flash" do
    sign_in_as users(:alice)
    visit team_path

    # Find Carol's row and click the remove button
    carol_row = find("[data-testid='team-member-row']", text: users(:member_carol).full_name)
    within(carol_row) do
      find("[data-testid='remove-member-button']").click
    end

    assert_text I18n.t(
      "authenticated.team_members.destroy.notice",
      name: users(:member_carol).full_name,
      account_name: accounts(:acme).name
    )
    assert_no_selector "[data-testid='team-member-row']", text: users(:member_carol).full_name
  end

  test "member does not see Remove buttons" do
    sign_in_as users(:member_carol)
    visit team_path

    assert_no_selector "[data-testid='remove-member-button']"
  end
end
