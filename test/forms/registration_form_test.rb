require "test_helper"

class RegistrationFormTest < ActiveSupport::TestCase
  def valid_params
    {
      email: "newuser@example.com",
      password: "securepassword",
      password_confirmation: "securepassword",
      first_name: "New",
      last_name: "User"
    }
  end

  # Validations

  test "valid with all required attributes" do
    form = RegistrationForm.new(valid_params)
    assert form.valid?
  end

  test "invalid without email" do
    form = RegistrationForm.new(valid_params.merge(email: ""))
    assert_not form.valid?
    assert form.errors[:email].any?
  end

  test "invalid with malformed email" do
    form = RegistrationForm.new(valid_params.merge(email: "not-an-email"))
    assert_not form.valid?
    assert form.errors[:email].any?
  end

  test "invalid without password" do
    form = RegistrationForm.new(valid_params.merge(password: ""))
    assert_not form.valid?
    assert form.errors[:password].any?
  end

  test "invalid without password confirmation" do
    form = RegistrationForm.new(valid_params.merge(password_confirmation: ""))
    assert_not form.valid?
    assert form.errors[:password_confirmation].any?
  end

  test "invalid when passwords do not match" do
    form = RegistrationForm.new(valid_params.merge(password_confirmation: "different"))
    assert_not form.valid?
    assert form.errors[:password_confirmation].any?
  end

  test "invalid when email already taken" do
    RegistrationForm.new(valid_params).save
    form = RegistrationForm.new(valid_params.merge(password: "anotherpass", password_confirmation: "anotherpass"))
    assert_not form.valid?
    assert form.errors[:email].any?
  end

  # Save — success

  test "save creates user, account, and account_user" do
    form = RegistrationForm.new(valid_params)

    assert_difference [ "User.count", "Account.count", "AccountUser.count" ], 1 do
      assert form.save
    end
  end

  test "save exposes user and account" do
    form = RegistrationForm.new(valid_params)
    form.save

    assert_instance_of User, form.user
    assert_instance_of Account, form.account
    assert_equal "newuser@example.com", form.user.email
  end

  test "save creates account_user with owner role" do
    form = RegistrationForm.new(valid_params)
    form.save

    account_user = AccountUser.find_by(user: form.user, account: form.account)
    assert_not_nil account_user
    assert_equal "owner", account_user.role
  end

  test "save sets account billing_status to trialing with 14-day trial" do
    form = RegistrationForm.new(valid_params)
    form.save

    assert_equal "trialing", form.account.billing_status
    assert_in_delta 14.days.from_now, form.account.trial_ends_at, 5.seconds
  end

  test "save derives account name from email domain" do
    form = RegistrationForm.new(valid_params.merge(email: "alice@umbrella.com"))
    form.save

    assert_equal "Umbrella", form.account.name
  end

  # Save — failure

  test "save returns false with invalid attributes" do
    form = RegistrationForm.new(valid_params.merge(email: "bad"))

    assert_not form.save
    assert form.errors[:email].any?
  end

  test "save does not persist any records on failure" do
    assert_no_difference [ "User.count", "Account.count", "AccountUser.count" ] do
      RegistrationForm.new(valid_params.merge(email: "bad")).save
    end
  end
end
