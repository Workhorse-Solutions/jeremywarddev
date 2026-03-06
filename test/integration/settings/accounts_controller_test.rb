require "test_helper"

class SettingsAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob   = users(:admin_bob)
    @carol = users(:member_carol)
  end

  test "GET /settings/account returns 200 for owner" do
    sign_in_as @alice
    get edit_settings_account_path
    assert_response :ok
  end

  test "GET /settings/account returns 200 for admin" do
    sign_in_as @bob
    get edit_settings_account_path
    assert_response :ok
  end

  test "GET /settings/account redirects member to dashboard with notice" do
    sign_in_as @carol
    get edit_settings_account_path
    assert_redirected_to dashboard_path
    assert_equal "You do not have permission to access account settings.", flash[:notice]
  end

  test "GET /settings/account redirects unauthenticated user to login" do
    get edit_settings_account_path
    assert_redirected_to login_path
  end

  test "PATCH /settings/account with valid name updates account and redirects" do
    sign_in_as @alice
    patch settings_account_path, params: { settings_account: { name: "New Name", slug: "" } }
    assert_redirected_to edit_settings_account_path
    assert_equal "Account updated successfully.", flash[:notice]
    assert_equal "New Name", accounts(:acme).reload.name
  end

  test "PATCH /settings/account with blank name re-renders form with error" do
    sign_in_as @alice
    patch settings_account_path, params: { settings_account: { name: "", slug: "" } }
    assert_response :unprocessable_entity
  end

  test "PATCH /settings/account by member redirects to dashboard" do
    sign_in_as @carol
    patch settings_account_path, params: { settings_account: { name: "Hacked" } }
    assert_redirected_to dashboard_path
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
