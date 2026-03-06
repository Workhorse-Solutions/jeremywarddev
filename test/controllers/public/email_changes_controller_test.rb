require "test_helper"

class Public::EmailChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @user.update!(unconfirmed_email: "newalice@example.com")
  end

  test "GET /confirm-email-change with valid token swaps email and redirects" do
    token = @user.generate_token_for(:email_change)

    assert_enqueued_emails 1 do
      get confirm_email_change_path, params: { token: token }
    end

    assert_redirected_to login_path
    assert_equal "newalice@example.com", @user.reload.email
    assert_nil @user.unconfirmed_email
    assert_equal I18n.t("public.email_changes.show.success"), flash[:notice]
  end

  test "GET /confirm-email-change with valid token sends notification to old email" do
    token = @user.generate_token_for(:email_change)

    get confirm_email_change_path, params: { token: token }

    notification = ActionMailer::Base.deliveries.last ||
      enqueued_jobs.find { |j| j["job_class"] == "ActionMailer::MailDeliveryJob" }
    assert_not_nil notification
  end

  test "GET /confirm-email-change with invalid token redirects with error" do
    get confirm_email_change_path, params: { token: "invalid-token" }

    assert_redirected_to login_path
    assert_equal I18n.t("public.email_changes.show.invalid_token"), flash[:alert]
    assert_equal "alice@acme.com", @user.reload.email
  end

  test "GET /confirm-email-change with expired token redirects with error" do
    token = @user.generate_token_for(:email_change)

    # Clear unconfirmed_email to invalidate the token (fingerprinted on unconfirmed_email)
    @user.update!(unconfirmed_email: nil)

    get confirm_email_change_path, params: { token: token }

    assert_redirected_to login_path
    assert_equal I18n.t("public.email_changes.show.invalid_token"), flash[:alert]
  end
end
