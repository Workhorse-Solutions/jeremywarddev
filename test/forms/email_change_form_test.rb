require "test_helper"

class EmailChangeFormTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  setup do
    @user = users(:alice)
  end

  def valid_params
    { new_email: "newalice@example.com", current_password: "password" }
  end

  def build_form(params = valid_params)
    form = EmailChangeForm.new(params)
    form.user = @user
    form
  end

  test "valid with correct params" do
    assert build_form.valid?
  end

  test "invalid without new_email" do
    form = build_form(valid_params.merge(new_email: ""))
    assert_not form.valid?
    assert form.errors[:new_email].any?
  end

  test "invalid with malformed email" do
    form = build_form(valid_params.merge(new_email: "not-an-email"))
    assert_not form.valid?
    assert form.errors[:new_email].any?
  end

  test "invalid without current_password" do
    form = build_form(valid_params.merge(current_password: ""))
    assert_not form.valid?
    assert form.errors[:current_password].any?
  end

  test "invalid with wrong current_password" do
    form = build_form(valid_params.merge(current_password: "wrongpassword"))
    assert_not form.valid?
    assert form.errors[:current_password].any?
  end

  test "invalid with duplicate email" do
    # Create another user with the target email
    other = User.create!(email: "newalice@example.com", password: "password12", password_confirmation: "password12")
    form = build_form(valid_params.merge(new_email: other.email))
    assert_not form.valid?
    assert form.errors[:new_email].any?
  end

  test "save stores unconfirmed_email and sends confirmation email" do
    form = build_form

    assert_enqueued_emails 1 do
      assert form.save
    end

    assert_equal "newalice@example.com", @user.reload.unconfirmed_email
    assert_equal "alice@acme.com", @user.email
  end

  test "save returns false with invalid params" do
    form = build_form(valid_params.merge(current_password: "wrong"))
    assert_not form.save
    assert_nil @user.reload.unconfirmed_email
  end
end
