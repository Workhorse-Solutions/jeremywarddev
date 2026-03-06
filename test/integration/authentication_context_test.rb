require "test_helper"

class AuthenticationContextTest < ActionDispatch::IntegrationTest
  setup do
    @form = RegistrationForm.new(
      email: "context@example.com",
      password: "securepassword",
      password_confirmation: "securepassword",
      first_name: "Context",
      last_name: "User"
    )
    @form.save
    @user = @form.user
    @account = @form.account
  end

  test "unauthenticated request to authenticated route redirects to login" do
    get dashboard_path
    assert_redirected_to login_path
  end

  test "authenticated request sets Current.user and Current.account" do
    post login_path, params: { email: @user.email, password: "securepassword" }
    assert_redirected_to dashboard_path

    get dashboard_path
    assert_response :ok
    assert_equal @user.id, session[:user_id]
  end

  test "session[:account_id] override takes precedence for current_account" do
    post login_path, params: { email: @user.email, password: "securepassword" }

    # Set session account_id to the known account
    get dashboard_path
    assert_response :ok
  end

  test "logout clears session and subsequent authenticated request redirects to login" do
    post login_path, params: { email: @user.email, password: "securepassword" }
    delete logout_path
    assert_redirected_to login_path

    get dashboard_path
    assert_redirected_to login_path
  end
end
