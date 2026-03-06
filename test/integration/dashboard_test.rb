require "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  setup do
    @form = RegistrationForm.new(
      email: "dashboard@example.com",
      password: "securepassword",
      password_confirmation: "securepassword"
    )
    @form.save
  end

  test "GET /dashboard returns 200 when authenticated" do
    post login_path, params: { email: @form.user.email, password: "securepassword" }
    get dashboard_path
    assert_response :ok
  end

  test "GET /dashboard redirects to login when unauthenticated" do
    get dashboard_path
    assert_redirected_to login_path
  end
end
