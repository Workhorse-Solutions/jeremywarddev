require_relative "../application_system_test_case"

class Authenticated::TeamSystemTest < ApplicationSystemTestCase
  test "member-role user sees team members list with roles but no management controls" do
    sign_in_as users(:member_carol)

    visit team_path

    assert_selector "[data-testid='team-member-row']"
    assert_text users(:alice).full_name
    assert_text users(:admin_bob).full_name
    assert_text users(:member_carol).full_name
    assert_text "owner"
    assert_text "admin"
    assert_text "member"

    # No invite or remove controls for member-role user
    assert_no_selector "[data-testid='remove-member-button']"
    assert_no_selector "a[href='#{new_team_invitation_path}']"
  end

  test "owner sees sort links on Name, Email, and Role columns" do
    sign_in_as users(:alice)
    visit team_path

    assert_selector "a[href*='sort=name']"
    assert_selector "a[href*='sort=email']"
    assert_selector "a[href*='sort=role']"
  end

  test "owner sees invite button and remove buttons" do
    sign_in_as users(:alice)
    visit team_path

    assert_selector "a[href='#{new_team_invitation_path}']"
    assert_selector "[data-testid='remove-member-button']"
  end
end
