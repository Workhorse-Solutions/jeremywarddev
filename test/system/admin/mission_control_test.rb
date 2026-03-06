require_relative "../application_system_test_case"

class Admin::MissionControlSystemTest < ApplicationSystemTestCase
  test "system_admin sees Mission Control dashboard at /system/jobs" do
    sign_in_as users(:admin_bob)
    visit "/system/jobs"
    assert_selector "title", text: /Mission control/i, visible: false
  end

  test "non-admin authenticated user visiting /system/jobs receives 404" do
    sign_in_as users(:alice)
    visit "/system/jobs"
    assert_equal 404, page.status_code
  end
end
