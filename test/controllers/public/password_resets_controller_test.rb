require "test_helper"

class Public::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  # GET /forgot-password
  test "GET /forgot-password renders the forgot password form" do
    get new_password_reset_path
    assert_response :ok
    assert_select "form"
    assert_select "input[type=email]"
  end

  # POST /forgot-password — existing email
  test "POST /forgot-password with existing email enqueues reset email" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      post new_password_reset_path, params: { email: users(:alice).email }
    end
    assert_redirected_to login_path
    assert_not_nil flash[:notice]
  end

  # POST /forgot-password — unknown email (neutral response, no email sent)
  test "POST /forgot-password with unknown email shows neutral flash without sending email" do
    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      post new_password_reset_path, params: { email: "nobody@example.com" }
    end
    assert_redirected_to login_path
    assert_not_nil flash[:notice]
  end

  # POST /forgot-password — neutral flash is identical for both cases
  test "POST /forgot-password flash is the same for existing and unknown email" do
    post new_password_reset_path, params: { email: users(:alice).email }
    existing_flash = flash[:notice]

    post new_password_reset_path, params: { email: "nobody@example.com" }
    unknown_flash = flash[:notice]

    assert_equal existing_flash, unknown_flash
  end

  # GET /reset-password?token=valid — renders reset form
  test "GET /reset-password with valid token renders form" do
    token = users(:alice).password_reset_token
    get edit_password_reset_path, params: { token: token }
    assert_response :ok
    assert_select "input[type=password]"
  end

  # GET /reset-password?token=invalid — redirects to forgot-password with error
  test "GET /reset-password with invalid token redirects to forgot-password" do
    get edit_password_reset_path, params: { token: "invalid-token" }
    assert_redirected_to new_password_reset_path
    assert_not_nil flash[:alert]
  end

  # PATCH /reset-password — valid token and matching passwords
  test "PATCH /reset-password with valid token updates password and invalidates sessions" do
    user = users(:alice)
    token = user.password_reset_token
    old_session_token = user.session_token

    patch edit_password_reset_path, params: {
      token: token,
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }

    assert_redirected_to login_path
    assert_not_nil flash[:notice]
    # Session token rotated to invalidate existing sessions
    assert_not_equal old_session_token, user.reload.session_token
  end

  # PATCH /reset-password — expired or invalid token
  test "PATCH /reset-password with expired token redirects to forgot-password" do
    patch edit_password_reset_path, params: {
      token: "invalid-token",
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to new_password_reset_path
    assert_not_nil flash[:alert]
  end

  # PATCH /reset-password — password too short
  test "PATCH /reset-password with short password re-renders form with error" do
    token = users(:alice).password_reset_token
    patch edit_password_reset_path, params: {
      token: token,
      password: "short",
      password_confirmation: "short"
    }
    assert_response :unprocessable_entity
  end

  # PATCH /reset-password — mismatched password confirmation
  test "PATCH /reset-password with mismatched confirmation re-renders form with error" do
    token = users(:alice).password_reset_token
    patch edit_password_reset_path, params: {
      token: token,
      password: "newpassword123",
      password_confirmation: "differentpassword"
    }
    assert_response :unprocessable_entity
  end
end
