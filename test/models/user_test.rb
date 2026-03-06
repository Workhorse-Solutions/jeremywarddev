require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Associations
  test "has many account_users" do
    assert_respond_to users(:alice), :account_users
  end

  test "has many accounts through account_users" do
    assert_respond_to users(:alice), :accounts
    assert_includes users(:alice).accounts, accounts(:acme)
  end

  # Validations: email
  test "valid with all required attributes" do
    user = User.new(email: "bob@example.com", password: "securepassword")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(password: "securepassword")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid with malformed email" do
    user = User.new(email: "not-an-email", password: "securepassword")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "invalid with duplicate email" do
    user = User.new(email: users(:alice).email, password: "securepassword")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  # has_secure_password
  test "authenticates with correct password" do
    assert users(:alice).authenticate("password")
  end

  test "does not authenticate with wrong password" do
    assert_not users(:alice).authenticate("wrong")
  end

  # system_admin
  test "system_admin defaults to false" do
    user = User.new(email: "newuser@example.com", password: "securepassword")
    assert_equal false, user.system_admin
  end

  test "system_admins scope returns only system admins" do
    assert_includes User.system_admins, users(:admin_bob)
    assert_not_includes User.system_admins, users(:alice)
  end

  # Password reset token (Rails built-in via has_secure_password reset_token:)
  test "password_reset_token generates a signed token" do
    user = users(:alice)
    token = user.password_reset_token
    assert_not_nil token
    assert_kind_of String, token
  end

  test "find_by_password_reset_token returns user for valid token" do
    user = users(:alice)
    token = user.password_reset_token
    found = User.find_by_password_reset_token(token)
    assert_equal user, found
  end

  test "find_by_password_reset_token returns nil for tampered token" do
    assert_nil User.find_by_password_reset_token("invalid")
  end

  test "password_reset_token is invalidated after password changes" do
    user = users(:alice)
    token = user.password_reset_token
    user.update!(password: "newpassword123")
    assert_nil User.find_by_password_reset_token(token)
  end

  # Email verification token (generates_token_for :email_verification)
  test "generate_token_for :email_verification returns a signed token" do
    user = users(:alice)
    token = user.generate_token_for(:email_verification)
    assert_not_nil token
  end

  test "find_by_token_for :email_verification finds user with valid token" do
    user = users(:alice)
    token = user.generate_token_for(:email_verification)
    assert_equal user, User.find_by_token_for(:email_verification, token)
  end

  test "find_by_token_for :email_verification returns nil after email is verified" do
    user = users(:alice)
    token = user.generate_token_for(:email_verification)
    user.mark_email_verified!
    assert_nil User.find_by_token_for(:email_verification, token)
  end

  test "mark_email_verified! sets email_verified_at" do
    user = users(:alice)
    user.mark_email_verified!
    assert_not_nil user.email_verified_at
  end

  test "email_verified? returns false when email_verified_at is nil" do
    user = users(:alice)
    assert_not user.email_verified?
  end

  test "email_verified? returns true when email_verified_at is set" do
    user = users(:alice)
    user.mark_email_verified!
    assert user.email_verified?
  end

  # Email change token (generates_token_for :email_change)
  test "generate_email_change_token! stores unconfirmed_email and returns signed token" do
    user = users(:alice)
    token = user.generate_email_change_token!("newemail@example.com")
    assert_equal "newemail@example.com", user.unconfirmed_email
    assert_not_nil token
    assert_kind_of String, token
  end

  test "find_by_token_for :email_change finds user with valid token" do
    user = users(:alice)
    token = user.generate_email_change_token!("newemail@example.com")
    assert_equal user, User.find_by_token_for(:email_change, token)
  end

  test "find_by_token_for :email_change returns nil after email change is confirmed" do
    user = users(:alice)
    token = user.generate_email_change_token!("newemail@example.com")
    user.confirm_email_change!
    assert_nil User.find_by_token_for(:email_change, token)
  end

  test "confirm_email_change! moves unconfirmed_email to email and clears it" do
    user = users(:alice)
    user.generate_email_change_token!("newemail@example.com")
    user.confirm_email_change!
    assert_equal "newemail@example.com", user.email
    assert_nil user.unconfirmed_email
  end
end
