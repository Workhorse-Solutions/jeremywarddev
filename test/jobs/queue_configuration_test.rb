require "test_helper"

class QueueConfigurationTest < ActiveJob::TestCase
  fixtures :users, :invitations, :accounts, :account_users

  test "UserMailer deliver_later enqueues to mailers queue" do
    assert_enqueued_with(queue: "mailers") do
      UserMailer.verification_email(users(:alice)).deliver_later
    end
  end

  test "InvitationMailer deliver_later enqueues to mailers queue" do
    assert_enqueued_with(queue: "mailers") do
      InvitationMailer.invite_email(invitations(:pending_invite)).deliver_later
    end
  end

  test "production queue adapter is solid_queue" do
    prod_config = Rails.root.join("config/environments/production.rb").read
    assert_includes prod_config, "queue_adapter = :solid_queue"
  end
end
