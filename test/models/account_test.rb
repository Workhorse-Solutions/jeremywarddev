require "test_helper"

class AccountTest < ActiveSupport::TestCase
  # Associations
  test "has many account_users" do
    assert_respond_to accounts(:acme), :account_users
  end

  test "has many users through account_users" do
    assert_respond_to accounts(:acme), :users
    assert_includes accounts(:acme).users, users(:alice)
  end

  # Validations: name
  test "valid with all required attributes" do
    account = Account.new(name: "Beta Corp", billing_status: "trialing")
    assert account.valid?
  end

  test "invalid without name" do
    account = Account.new(billing_status: "trialing")
    assert_not account.valid?
    assert_includes account.errors[:name], "can't be blank"
  end

  # Validations: billing_status
  test "valid with each allowed billing_status" do
    %w[trialing active past_due canceled].each do |status|
      account = Account.new(name: "Corp", billing_status: status)
      assert account.valid?, "Expected #{status} to be valid"
    end
  end

  test "invalid with unknown billing_status" do
    account = Account.new(name: "Corp", billing_status: "unknown")
    assert_not account.valid?
    assert account.errors[:billing_status].any?
  end
end
