require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_bob)
    @user = users(:alice)
  end

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end

  test "GET /admin/users returns 200 for admin" do
    sign_in_as @admin
    get admin_users_path
    assert_response :ok
  end

  test "GET /admin/users returns 404 for non-admin" do
    sign_in_as @user
    get admin_users_path
    assert_response :not_found
  end

  test "GET /admin/users redirects unauthenticated user" do
    get admin_users_path
    assert_redirected_to login_path
  end

  test "GET /admin/users shows users in the table" do
    sign_in_as @admin
    get admin_users_path
    assert_response :ok
    assert_select "table"
    assert_select "td", text: @user.email
  end

  test "GET /admin/users with search filters results" do
    sign_in_as @admin
    get admin_users_path, params: { q: "alice" }
    assert_response :ok
    assert_select "td", text: @user.email
  end

  test "GET /admin/users search with non-matching query returns no results" do
    sign_in_as @admin
    get admin_users_path, params: { q: "zzzznonexistent" }
    assert_response :ok
    assert_select "td", text: @user.email, count: 0
  end

  # AQL-013: Admin — manually verify a user's email

  test "POST /admin/users/:id/verify_email verifies an unverified user" do
    sign_in_as @admin
    assert_nil @user.email_verified_at

    post verify_email_admin_user_path(@user)

    assert_redirected_to admin_users_path
    assert_equal I18n.t("admin.users.verify_email.success"), flash[:notice]
    @user.reload
    assert @user.email_verified?
  end

  test "POST /admin/users/:id/verify_email shows notice for already verified user" do
    sign_in_as @admin
    @user.mark_email_verified!

    post verify_email_admin_user_path(@user)

    assert_redirected_to admin_users_path
    assert_equal I18n.t("admin.users.verify_email.already_verified"), flash[:notice]
  end

  test "POST /admin/users/:id/verify_email returns 404 for non-admin" do
    sign_in_as @user
    post verify_email_admin_user_path(@user)
    assert_response :not_found
  end

  test "POST /admin/users/:id/verify_email returns 404 for not-found user" do
    sign_in_as @admin
    post verify_email_admin_user_path(id: 999_999)
    assert_response :not_found
  end

  # AQL-014: Admin — force password reset

  test "POST /admin/users/:id/force_password_reset sends reset email and invalidates sessions" do
    sign_in_as @admin
    old_session_token = @user.session_token

    assert_enqueued_emails 1 do
      post force_password_reset_admin_user_path(@user)
    end

    assert_redirected_to admin_users_path
    assert_equal I18n.t("admin.users.force_password_reset.success"), flash[:notice]
    @user.reload
    assert_not_equal old_session_token, @user.session_token
  end

  test "POST /admin/users/:id/force_password_reset returns 404 for non-admin" do
    sign_in_as @user
    post force_password_reset_admin_user_path(@user)
    assert_response :not_found
  end

  test "POST /admin/users/:id/force_password_reset returns 404 for not-found user" do
    sign_in_as @admin
    post force_password_reset_admin_user_path(id: 999_999)
    assert_response :not_found
  end

  # AQL-015: Admin — impersonate user

  test "POST /admin/users/:id/impersonate starts impersonation" do
    sign_in_as @admin
    post impersonate_admin_user_path(@user)

    assert_redirected_to dashboard_path
    assert_equal I18n.t("admin.impersonations.start.success", name: @user.full_name), flash[:notice]

    # Verify we are now acting as the impersonated user
    get dashboard_path
    assert_response :ok
  end

  test "POST /admin/users/:id/impersonate is not nestable" do
    sign_in_as @admin
    post impersonate_admin_user_path(@user)
    follow_redirect!

    # Try to impersonate again — should be blocked
    # Need to access admin route, but current user is alice (non-admin)
    # The admin guard will return 404 since alice is not admin
    post impersonate_admin_user_path(@admin)
    assert_response :not_found
  end

  test "POST /admin/users/:id/impersonate returns 404 for non-admin" do
    sign_in_as @user
    post impersonate_admin_user_path(@admin)
    assert_response :not_found
  end

  test "DELETE /admin/impersonation stops impersonation and restores admin session" do
    sign_in_as @admin
    post impersonate_admin_user_path(@user)
    follow_redirect!

    delete admin_impersonation_path

    assert_redirected_to admin_users_path
    assert_equal I18n.t("admin.impersonations.stop.success"), flash[:notice]

    # Verify admin session is restored — can access admin page
    get admin_users_path
    assert_response :ok
  end

  test "DELETE /admin/impersonation returns 404 when not impersonating" do
    sign_in_as @admin
    delete admin_impersonation_path
    assert_response :not_found
  end
end
