require "test_helper"

class Authenticated::EmailChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    post login_path, params: { email: @user.email, password: "password" }
  end

  test "GET /settings/email renders the email change form" do
    get edit_email_settings_path
    assert_response :ok
  end

  test "PATCH /settings/email with valid params sends confirmation email and redirects" do
    assert_enqueued_emails 1 do
      patch edit_email_settings_path, params: {
        email_change: { new_email: "new@example.com", current_password: "password" }
      }
    end

    assert_redirected_to edit_settings_profile_path
    assert_equal "new@example.com", @user.reload.unconfirmed_email
    assert_equal "alice@acme.com", @user.email
  end

  test "PATCH /settings/email with wrong password re-renders with errors" do
    patch edit_email_settings_path, params: {
      email_change: { new_email: "new@example.com", current_password: "wrongpassword" }
    }

    assert_response :unprocessable_entity
    assert_nil @user.reload.unconfirmed_email
  end

  test "PATCH /settings/email with duplicate email re-renders with errors" do
    User.create!(email: "taken@example.com", password: "password12", password_confirmation: "password12")

    patch edit_email_settings_path, params: {
      email_change: { new_email: "taken@example.com", current_password: "password" }
    }

    assert_response :unprocessable_entity
    assert_nil @user.reload.unconfirmed_email
  end

  test "GET /settings/email requires authentication" do
    delete logout_path
    get edit_email_settings_path
    assert_redirected_to login_path
  end
end
