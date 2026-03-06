require "test_helper"

class TeamMembersTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)          # owner
    @bob = users(:admin_bob)        # admin
    @carol = users(:member_carol)   # member
  end

  test "owner can remove a member" do
    sign_in_as @alice

    assert_difference "AccountUser.count", -1 do
      delete team_member_path(account_users(:carol_acme))
    end

    assert_redirected_to team_path
    follow_redirect!
    assert_select "div", text: /#{@carol.full_name} has been removed/
  end

  test "owner can remove an admin" do
    sign_in_as @alice

    assert_difference "AccountUser.count", -1 do
      delete team_member_path(account_users(:bob_acme))
    end

    assert_redirected_to team_path
  end

  test "admin can remove a member" do
    sign_in_as @bob

    assert_difference "AccountUser.count", -1 do
      delete team_member_path(account_users(:carol_acme))
    end

    assert_redirected_to team_path
  end

  test "admin cannot remove an owner" do
    sign_in_as @bob

    assert_no_difference "AccountUser.count" do
      delete team_member_path(account_users(:alice_acme))
    end

    assert_redirected_to team_path
    follow_redirect!
    assert_select "div", text: /do not have permission to remove an owner/
  end

  test "member cannot remove anyone" do
    sign_in_as @carol

    assert_no_difference "AccountUser.count" do
      delete team_member_path(account_users(:bob_acme))
    end

    assert_redirected_to team_path
  end

  test "last owner cannot be removed" do
    sign_in_as @alice

    assert_no_difference "AccountUser.count" do
      delete team_member_path(account_users(:alice_acme))
    end

    assert_redirected_to team_path
    follow_redirect!
    assert_select "div", text: /cannot remove the last owner/
  end

  test "owner sees Remove buttons on team page" do
    sign_in_as @alice
    get team_path

    assert_select "[data-testid='remove-member-button']"
  end

  test "member does not see Remove buttons on team page" do
    sign_in_as @carol
    get team_path

    assert_select "[data-testid='remove-member-button']", count: 0
  end

  test "removed user loses access to the account" do
    sign_in_as @alice
    delete team_member_path(account_users(:carol_acme))

    # Carol logs in — should have no account access
    post logout_path
    sign_in_as @carol
    get dashboard_path
    # Carol has no accounts left, so authenticate! redirects to login
    assert_redirected_to login_path
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
