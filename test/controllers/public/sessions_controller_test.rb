require "test_helper"

class Public::SessionsControllerTest < ActionDispatch::IntegrationTest
  # GET /login
  test "GET /login renders login form" do
    get login_path
    assert_response :ok
    assert_select "form"
    assert_select "input[type=email]"
    assert_select "input[type=password]"
  end

  # POST /login — success
  test "POST /login with valid credentials sets session and redirects to dashboard" do
    post login_path, params: { email: users(:alice).email, password: "password" }

    assert_redirected_to dashboard_path
    assert_equal users(:alice).id, session[:user_id]
  end

  # POST /login — failure: wrong password
  test "POST /login with wrong password re-renders form with error" do
    post login_path, params: { email: users(:alice).email, password: "wrongpassword" }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select "div.alert-error"
  end

  # POST /login — failure: unknown email
  test "POST /login with unknown email re-renders form with error" do
    post login_path, params: { email: "nobody@example.com", password: "password" }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select "div.alert-error"
  end

  # DELETE /logout
  test "DELETE /logout clears session and redirects to login" do
    post login_path, params: { email: users(:alice).email, password: "password" }
    assert_equal users(:alice).id, session[:user_id]

    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end
end
