require "test_helper"

class SettingsProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @carol = users(:member_carol)
  end

  test "GET /settings/profile returns 200 for owner" do
    sign_in_as @alice
    get edit_settings_profile_path
    assert_response :ok
  end

  test "GET /settings/profile returns 200 for member" do
    sign_in_as @carol
    get edit_settings_profile_path
    assert_response :ok
  end

  test "GET /settings/profile redirects unauthenticated user to login" do
    get edit_settings_profile_path
    assert_redirected_to login_path
  end

  test "PATCH /settings/profile updates name and redirects with notice" do
    sign_in_as @alice
    patch settings_profile_path, params: { settings_profile: { first_name: "Alicia", last_name: "Smith" } }
    assert_redirected_to edit_settings_profile_path
    assert_equal "Profile updated successfully.", flash[:notice]
    assert_equal "Alicia", @alice.reload.first_name
    assert_equal "Smith", @alice.reload.last_name
  end

  test "PATCH /settings/profile redirects unauthenticated user to login" do
    patch settings_profile_path, params: { settings_profile: { first_name: "X" } }
    assert_redirected_to login_path
  end

  test "PATCH /settings/profile/password with correct password updates and redirects" do
    sign_in_as @alice
    old_token = @alice.reload.session_token
    patch settings_profile_password_path, params: {
      settings_password: {
        current_password: "password",
        password: "newpassword1",
        password_confirmation: "newpassword1"
      }
    }
    assert_redirected_to edit_settings_profile_path
    assert_equal "Password updated successfully.", flash[:notice]
    assert_not_equal old_token, @alice.reload.session_token
  end

  test "PATCH /settings/profile/password with wrong current password re-renders with error" do
    sign_in_as @alice
    patch settings_profile_password_path, params: {
      settings_password: {
        current_password: "wrongpassword",
        password: "newpassword1",
        password_confirmation: "newpassword1"
      }
    }
    assert_response :unprocessable_entity
  end

  test "PATCH /settings/profile/password with mismatched passwords re-renders with error" do
    sign_in_as @alice
    patch settings_profile_password_path, params: {
      settings_password: {
        current_password: "password",
        password: "newpassword1",
        password_confirmation: "differentpassword"
      }
    }
    assert_response :unprocessable_entity
  end

  test "PATCH /settings/profile/password redirects unauthenticated user to login" do
    patch settings_profile_password_path, params: { settings_password: {} }
    assert_redirected_to login_path
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
