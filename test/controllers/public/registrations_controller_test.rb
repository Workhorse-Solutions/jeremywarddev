require "test_helper"

class Public::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  def valid_signup_params
    {
      registration: {
        email: "newuser@example.com",
        password: "securepassword",
        password_confirmation: "securepassword",
        name: "New User"
      }
    }
  end

  # GET /signup
  test "GET /signup renders signup form" do
    get signup_path
    assert_response :ok
    assert_select "form"
    assert_select "input[type=email]"
    assert_select "input[type=password]"
  end

  # POST /signup — success
  test "POST /signup with valid params creates user, account, account_user" do
    assert_difference [ "User.count", "Account.count", "AccountUser.count" ], 1 do
      post signup_path, params: valid_signup_params
    end

    assert_redirected_to dashboard_path
  end

  test "POST /signup enqueues verification email on success" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      post signup_path, params: valid_signup_params
    end
  end

  test "POST /signup sets session on success" do
    post signup_path, params: valid_signup_params
    assert_not_nil session[:user_id]
    assert_equal User.find_by(email: "newuser@example.com").id, session[:user_id]
  end

  # POST /signup — system_admin cannot be set via signup params
  test "POST /signup ignores system_admin param silently" do
    post signup_path, params: {
      registration: valid_signup_params[:registration].merge(system_admin: true)
    }

    user = User.find_by(email: "newuser@example.com")
    assert_not_nil user
    assert_not user.system_admin?, "system_admin must not be settable via signup"
  end

  # POST /signup — failure
  test "POST /signup with invalid email re-renders form with errors" do
    post signup_path, params: { registration: valid_signup_params[:registration].merge(email: "bad") }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select "p.text-error"
  end

  test "POST /signup with password mismatch re-renders form with errors" do
    post signup_path, params: {
      registration: valid_signup_params[:registration].merge(password_confirmation: "different")
    }

    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select "p.text-error"
  end

  test "POST /signup with duplicate email re-renders form with errors" do
    post signup_path, params: valid_signup_params
    post signup_path, params: valid_signup_params

    assert_response :unprocessable_entity
    assert_select "p.text-error"
  end

  test "POST /signup failure does not persist any records" do
    assert_no_difference [ "User.count", "Account.count", "AccountUser.count" ] do
      post signup_path, params: { registration: valid_signup_params[:registration].merge(email: "bad") }
    end
  end
end
