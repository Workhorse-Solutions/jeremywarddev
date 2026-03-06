require "test_helper"

class AccountUserTest < ActiveSupport::TestCase
  # Associations
  test "belongs to account" do
    assert_respond_to account_users(:alice_acme), :account
    assert_equal accounts(:acme), account_users(:alice_acme).account
  end

  test "belongs to user" do
    assert_respond_to account_users(:alice_acme), :user
    assert_equal users(:alice), account_users(:alice_acme).user
  end

  # Validations: role
  test "valid with each allowed role" do
    %w[owner admin member].each do |role|
      au = AccountUser.new(
        account: accounts(:acme),
        user: User.new(email: "#{role}@example.com", password: "pass"),
        role: role
      )
      assert au.valid?, "Expected role '#{role}' to be valid"
    end
  end

  test "invalid with unknown role" do
    au = AccountUser.new(account: accounts(:acme), user: users(:alice), role: "superuser")
    assert_not au.valid?
    assert au.errors[:role].any?
  end

  test "invalid without role" do
    au = AccountUser.new(account: accounts(:acme), user: users(:alice), role: nil)
    assert_not au.valid?
  end
end
