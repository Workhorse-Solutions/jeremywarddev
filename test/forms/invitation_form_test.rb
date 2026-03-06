require "test_helper"

class InvitationFormTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @account = accounts(:acme)
    @alice = users(:alice)
  end

  test "valid invitation creates record and enqueues email" do
    form = InvitationForm.new(
      account: @account,
      invited_by: @alice,
      email: "newuser@example.com"
    )

    assert_difference "Invitation.count", 1 do
      assert_enqueued_emails 1 do
        assert form.save
      end
    end

    assert_equal "newuser@example.com", form.invitation.email
    assert_equal @account, form.invitation.account
    assert_equal @alice, form.invitation.invited_by_user
  end

  test "rejects blank email" do
    form = InvitationForm.new(account: @account, invited_by: @alice, email: "")
    assert_not form.save
    assert form.errors[:email].any?
  end

  test "rejects invalid email format" do
    form = InvitationForm.new(account: @account, invited_by: @alice, email: "not-an-email")
    assert_not form.save
    assert form.errors[:email].any?
  end

  test "rejects email of existing member" do
    form = InvitationForm.new(account: @account, invited_by: @alice, email: users(:member_carol).email)
    assert_not form.save
    assert_includes form.errors[:email], "This person is already a member."
  end

  test "rejects email with pending invitation" do
    form = InvitationForm.new(account: @account, invited_by: @alice, email: "pending@example.com")
    assert_not form.save
    assert_includes form.errors[:email], "An invitation for this email is already pending."
  end
end
