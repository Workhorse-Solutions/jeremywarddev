require "test_helper"

# Lightweight model class used exclusively to test AccountScoped in isolation.
# Backed by the invitations table which already has the right schema.
class AccountScopedTestRecord < ApplicationRecord
  include AccountScoped
  self.table_name = "invitations"

  belongs_to :invited_by_user, class_name: "User"
end

class AccountScopedTest < ActiveSupport::TestCase
  setup do
    @klass = AccountScopedTestRecord
  end

  teardown do
    Current.account = nil
  end

  # --- Association ---

  test "adds belongs_to :account association" do
    reflection = @klass.reflect_on_association(:account)
    assert_not_nil reflection
    assert_equal :belongs_to, reflection.macro
  end

  # --- Validation ---

  test "record without account is invalid" do
    record = @klass.new(
      invited_by_user: users(:alice),
      email: "test@example.com",
      expires_at: 7.days.from_now
    )
    assert_not record.valid?
    assert_includes record.errors[:account], "must exist"
  end

  # --- .for_account scope ---

  test ".for_account returns only records belonging to the given account" do
    acme = accounts(:acme)
    other = Account.create!(name: "Other Co", billing_status: "trialing")

    acme_record = @klass.create!(
      account: acme,
      invited_by_user: users(:alice),
      email: "acme@example.com",
      expires_at: 7.days.from_now
    )
    other_record = @klass.create!(
      account: other,
      invited_by_user: users(:alice),
      email: "other@example.com",
      expires_at: 7.days.from_now
    )

    scoped = @klass.for_account(acme)
    assert_includes scoped, acme_record
    assert_not_includes scoped, other_record
  end

  # --- .for_current_account scope ---

  test ".for_current_account returns records for Current.account" do
    acme = accounts(:acme)
    other = Account.create!(name: "Other Co", billing_status: "trialing")

    acme_record = @klass.create!(
      account: acme,
      invited_by_user: users(:alice),
      email: "acme2@example.com",
      expires_at: 7.days.from_now
    )
    other_record = @klass.create!(
      account: other,
      invited_by_user: users(:alice),
      email: "other2@example.com",
      expires_at: 7.days.from_now
    )

    Current.account = acme
    scoped = @klass.for_current_account

    assert_includes scoped, acme_record
    assert_not_includes scoped, other_record
  end

  test ".for_current_account raises when Current.account is not set" do
    Current.account = nil

    assert_raises(AccountScoped::CurrentAccountNotSet) do
      @klass.for_current_account.to_a
    end
  end
end
