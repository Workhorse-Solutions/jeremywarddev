require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @invitation = invitations(:pending_invite)
  end

  test "pending scope returns unexpired and unaccepted invitations" do
    assert_includes Invitation.pending, @invitation
  end

  test "pending scope excludes accepted invitations" do
    @invitation.update!(accepted_at: Time.current)
    assert_not_includes Invitation.pending, @invitation
  end

  test "pending scope excludes expired invitations" do
    @invitation.update!(expires_at: 1.day.ago)
    assert_not_includes Invitation.pending, @invitation
  end

  test "accepted? returns true when accepted_at is set" do
    @invitation.update!(accepted_at: Time.current)
    assert @invitation.accepted?
  end

  test "accepted? returns false when accepted_at is nil" do
    assert_not @invitation.accepted?
  end

  test "expired? returns true when expired" do
    @invitation.update!(expires_at: 1.day.ago)
    assert @invitation.expired?
  end

  test "expired? returns false when not expired" do
    assert_not @invitation.expired?
  end

  test "accept! creates account user and marks as accepted" do
    user = User.create!(
      email: "pending@example.com",
      password: "password12",
      password_confirmation: "password12"
    )

    assert_difference "AccountUser.count", 1 do
      @invitation.accept!(user)
    end

    assert @invitation.reload.accepted?
    assert_equal "member", AccountUser.find_by(user: user, account: @invitation.account).role
  end

  test "generates_token_for produces a valid token" do
    token = @invitation.generate_token_for(:acceptance)
    found = Invitation.find_by_token_for(:acceptance, token)
    assert_equal @invitation, found
  end

  test "token is invalidated after acceptance" do
    token = @invitation.generate_token_for(:acceptance)
    @invitation.update!(accepted_at: Time.current)
    found = Invitation.find_by_token_for(:acceptance, token)
    assert_nil found
  end
end
