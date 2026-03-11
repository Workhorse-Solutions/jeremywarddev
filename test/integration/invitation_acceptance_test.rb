require "test_helper"

class InvitationAcceptanceTest < ActionDispatch::IntegrationTest
  setup do
    @invitation = invitations(:pending_invite)
    @token = @invitation.generate_token_for(:acceptance)
  end

  test "GET /invitations/:token shows acceptance page for valid token" do
    get invitation_path(token: @token)
    assert_response :ok
    assert_select "[data-testid='invitation-error']", count: 0
  end

  test "GET /invitations/:token shows error for invalid token" do
    get invitation_path(token: "invalid-token")
    assert_response :ok
    assert_select "[data-testid='invitation-error']"
  end

  test "GET /invitations/:token shows error for already-accepted invitation" do
    @invitation.update!(accepted_at: Time.current)
    # Token is fingerprinted on accepted_at, so old token is now invalid
    get invitation_path(token: @token)
    assert_response :ok
    assert_select "[data-testid='invitation-error']"
  end

  test "GET /invitations/:token shows error when logged in as wrong email" do
    sign_in_as users(:alice)
    get invitation_path(token: @token)
    assert_response :ok
    assert_select "[data-testid='invitation-error']"
  end

  test "POST accept redirects to login for unauthenticated visitor with existing account" do
    User.create!(email: "pending@example.com", password: "password12", password_confirmation: "password12")

    post accept_invitation_path(token: @token)

    assert_redirected_to login_path
    assert_equal @token, session[:pending_invitation_token]
  end

  test "POST accept redirects to login for unauthenticated visitor without account" do
    post accept_invitation_path(token: @token)

    assert_redirected_to login_path
    assert_equal @token, session[:pending_invitation_token]
  end

  test "POST accept creates account user for logged-in user with matching email" do
    user = User.create!(email: "pending@example.com", password: "password", password_confirmation: "password")
    sign_in_as user

    assert_difference "AccountUser.count", 1 do
      post accept_invitation_path(token: @token)
    end

    assert_redirected_to dashboard_path
    assert @invitation.reload.accepted?
    assert AccountUser.exists?(user: user, account: @invitation.account, role: "member")
  end

  test "POST accept rejects logged-in user with wrong email" do
    sign_in_as users(:alice)

    assert_no_difference "AccountUser.count" do
      post accept_invitation_path(token: @token)
    end

    assert_redirected_to invitation_path(token: @token)
  end

  test "POST accept rejects invalid token" do
    post accept_invitation_path(token: "invalid-token")
    assert_redirected_to root_path
  end

  test "POST accept rejects already-accepted invitation" do
    @invitation.update!(accepted_at: Time.current)
    post accept_invitation_path(token: @token)
    assert_redirected_to root_path
  end

  test "login redirects to invitation page when pending token in session" do
    User.create!(email: "pending@example.com", password: "password", password_confirmation: "password")

    # Simulate: unauthenticated visitor tries to accept, gets redirected to login
    post accept_invitation_path(token: @token)
    assert_redirected_to login_path

    # Now log in
    post login_path, params: { email: "pending@example.com", password: "password" }
    assert_redirected_to invitation_path(token: @token)
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
