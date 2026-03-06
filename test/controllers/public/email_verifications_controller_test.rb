require "test_helper"

class Public::EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  # GET /verify-email (no token) — renders info page
  test "GET /verify-email without token renders info page" do
    get verify_email_path
    assert_response :ok
  end

  # GET /verify-email?token=valid — marks verified, signs in, redirects to dashboard
  test "GET /verify-email with valid token verifies email and redirects to dashboard" do
    user = users(:alice)
    refute user.email_verified?

    token = user.generate_token_for(:email_verification)
    get verify_email_path, params: { token: token }

    assert_redirected_to dashboard_path
    assert user.reload.email_verified?
    assert_equal user.id, session[:user_id]
    assert_not_nil flash[:notice]
  end

  # GET /verify-email?token=valid while already signed in — verifies but keeps existing session
  test "GET /verify-email with valid token while already signed in keeps session" do
    user = users(:alice)
    post login_path, params: { email: user.email, password: "password" }
    assert_equal user.id, session[:user_id]

    token = user.generate_token_for(:email_verification)
    get verify_email_path, params: { token: token }

    assert_redirected_to dashboard_path
    assert user.reload.email_verified?
    assert_equal user.id, session[:user_id]
  end

  # GET /verify-email?token=invalid — redirects to verify_email_path with error flash
  test "GET /verify-email with invalid token redirects with error flash" do
    get verify_email_path, params: { token: "invalid-token" }
    assert_redirected_to verify_email_path
    assert_not_nil flash[:alert]
  end

  # GET /verify-email?token=expired — already verified token is invalid (fingerprinted)
  test "GET /verify-email with token for already-verified user redirects with error flash" do
    user = users(:alice)
    token = user.generate_token_for(:email_verification)

    # Verify first time
    user.mark_email_verified!

    # Token is now invalidated (fingerprinted on email_verified_at)
    get verify_email_path, params: { token: token }
    assert_redirected_to verify_email_path
    assert_not_nil flash[:alert]
  end

  # POST /resend-verification — sends new verification email and shows neutral flash
  test "POST /resend-verification with unverified user email sends verification and shows neutral flash" do
    user = users(:alice)
    refute user.email_verified?

    assert_enqueued_emails 1 do
      post resend_verification_path, params: { email: user.email }
    end

    assert_redirected_to verify_email_path
    assert_equal I18n.t("public.email_verifications.resend.notice"), flash[:notice]
  end

  test "POST /resend-verification with unknown email shows same neutral flash" do
    assert_no_enqueued_emails do
      post resend_verification_path, params: { email: "nonexistent@example.com" }
    end

    assert_redirected_to verify_email_path
    assert_equal I18n.t("public.email_verifications.resend.notice"), flash[:notice]
  end

  test "POST /resend-verification with already-verified user does not send email" do
    user = users(:alice)
    user.mark_email_verified!

    assert_no_enqueued_emails do
      post resend_verification_path, params: { email: user.email }
    end

    assert_redirected_to verify_email_path
    assert_equal I18n.t("public.email_verifications.resend.notice"), flash[:notice]
  end
end
