require "test_helper"

class InvitationsTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)        # owner
    @bob = users(:admin_bob)      # admin
    @carol = users(:member_carol) # member
  end

  test "owner can create an invitation" do
    sign_in_as @alice

    assert_difference "Invitation.count", 1 do
      assert_enqueued_emails 1 do
        post team_invitations_path, params: { invitation_form: { email: "newperson@example.com" } }
      end
    end

    assert_redirected_to team_path
    follow_redirect!
    assert_select "div", text: /Invitation sent to newperson@example.com/
  end

  test "admin can create an invitation" do
    sign_in_as @bob

    assert_difference "Invitation.count", 1 do
      post team_invitations_path, params: { invitation_form: { email: "newperson@example.com" } }
    end

    assert_redirected_to team_path
  end

  test "member cannot create an invitation" do
    sign_in_as @carol

    assert_no_difference "Invitation.count" do
      post team_invitations_path, params: { invitation_form: { email: "newperson@example.com" } }
    end

    assert_redirected_to team_path
  end

  test "cannot invite existing member" do
    sign_in_as @alice

    assert_no_difference "Invitation.count" do
      post team_invitations_path, params: { invitation_form: { email: @carol.email } }
    end

    assert_response :unprocessable_entity
    assert_select "p", text: /already a member/
  end

  test "cannot invite email with pending invitation" do
    sign_in_as @alice

    assert_no_difference "Invitation.count" do
      post team_invitations_path, params: { invitation_form: { email: "pending@example.com" } }
    end

    assert_response :unprocessable_entity
    assert_select "p", text: /already pending/
  end

  test "owner sees invite button on team page" do
    sign_in_as @alice
    get team_path

    assert_select "a[href='#{new_team_invitation_path}']"
  end

  test "member does not see invite button on team page" do
    sign_in_as @carol
    get team_path

    assert_select "a[href='#{new_team_invitation_path}']", count: 0
  end

  test "owner sees pending invitations on team page" do
    sign_in_as @alice
    get team_path

    assert_select "[data-testid='pending-invitation-row']", count: 1
  end

  test "member does not see pending invitations on team page" do
    sign_in_as @carol
    get team_path

    assert_select "[data-testid='pending-invitation-row']", count: 0
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
