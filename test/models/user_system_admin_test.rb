require "test_helper"

class UserSystemAdminTest < ActiveSupport::TestCase
  test "system_admin? returns false by default" do
    user = User.new(email: "test@example.com", password: "securepassword")
    assert_not user.system_admin?
  end

  test "system_admin? returns true for system admin users" do
    users(:alice).update_column(:system_admin, true)
    assert users(:alice).system_admin?
  end

  test "system_admins scope returns users with system_admin true" do
    assert_includes User.system_admins, users(:admin_bob)
    assert_not_includes User.system_admins, users(:alice)
  end

  test "system_admin is not settable via signup permitted params" do
    permitted_params = ActionController::Parameters.new(
      user: {
        email: "attacker@example.com",
        password: "securepassword",
        password_confirmation: "securepassword",
        first_name: "Attacker",
        system_admin: true
      }
    ).require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)

    user = User.new(permitted_params)
    user.save!
    assert_not user.system_admin?, "system_admin must not be settable via signup params"
  end
end
