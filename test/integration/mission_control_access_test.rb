require "test_helper"

class MissionControlAccessTest < ActionDispatch::IntegrationTest
  test "unauthenticated request to /system/jobs returns 404" do
    get "/system/jobs"
    assert_response :not_found
  end

  test "authenticated non-admin user visiting /system/jobs receives 404" do
    post login_path, params: { email: users(:alice).email, password: "password" }
    get "/system/jobs"
    assert_response :not_found
  end

  test "system_admin user visiting /system/jobs receives 200" do
    post login_path, params: { email: users(:admin_bob).email, password: "password" }
    get "/system/jobs"
    assert_response :ok
  end
end
