require "test_helper"

class Authenticated::EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    post login_path, params: { email: @user.email, password: "password" }
  end

  test "POST /resend-verification enqueues verification email" do
    assert_enqueued_emails 1 do
      post resend_email_verification_path
    end
  end

  test "POST /resend-verification does not enqueue email if already verified" do
    @user.mark_email_verified!

    assert_no_enqueued_emails do
      post resend_email_verification_path
    end
  end

  test "POST /resend-verification as turbo_stream replaces banner" do
    post resend_email_verification_path, as: :turbo_stream

    assert_response :ok
    assert_select "turbo-stream[action='replace'][target='email-verification-banner']"
  end

  test "POST /resend-verification as HTML redirects to dashboard" do
    post resend_email_verification_path

    assert_redirected_to dashboard_path
  end

  test "POST /resend-verification requires authentication" do
    delete logout_path
    post resend_email_verification_path

    assert_redirected_to login_path
  end
end
