require_relative "../application_system_test_case"

class Admin::UsersSystemTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin_bob)
    sign_in_as @admin
  end

  test "admin users page renders a table with user details" do
    visit admin_users_path

    assert_selector "table"
    assert_text users(:alice).email
    assert_text users(:alice).full_name
  end

  test "search filters visible users" do
    visit admin_users_path

    fill_in :q, with: "alice"
    click_button I18n.t("admin.users.index.search_submit")

    assert_text users(:alice).email
  end

  # AQL-013: Admin — manually verify a user's email

  test "admin can verify an unverified user's email" do
    assert_not users(:alice).email_verified?

    visit admin_users_path
    alice_row = find("tr", text: users(:alice).email)
    within(alice_row) do
      assert_selector ".badge", text: I18n.t("admin.users.index.verified_no")
      click_button I18n.t("admin.users.index.verify_action")
    end

    assert_text I18n.t("admin.users.verify_email.success")
    alice_row = find("tr", text: users(:alice).email)
    within(alice_row) do
      assert_selector ".badge", text: I18n.t("admin.users.index.verified_yes")
      assert_no_button I18n.t("admin.users.index.verify_action")
    end
  end

  test "verifying an already-verified user shows a notice" do
    users(:alice).mark_email_verified!

    visit admin_users_path
    alice_row = find("tr", text: users(:alice).email)
    within(alice_row) do
      assert_selector ".badge", text: I18n.t("admin.users.index.verified_yes")
      assert_no_button I18n.t("admin.users.index.verify_action")
    end
  end

  # AQL-014: Admin — force password reset

  test "admin can force a password reset for a user" do
    visit admin_users_path
    alice_row = find("tr", text: users(:alice).email)
    within(alice_row) do
      click_button I18n.t("admin.users.index.force_reset_action")
    end

    assert_text I18n.t("admin.users.force_password_reset.success")
  end

  # AQL-015: Admin — impersonate user

  test "admin can impersonate a user and see the banner then stop" do
    visit admin_users_path
    alice_row = find("tr", text: users(:alice).email)
    within(alice_row) do
      click_button I18n.t("admin.users.index.impersonate_action")
    end

    # Should see impersonation banner with user's name
    assert_selector "[data-testid='impersonation-banner']"
    assert_text I18n.t("authenticated.impersonation_banner.message", name: users(:alice).full_name)
    assert_button I18n.t("authenticated.impersonation_banner.stop")

    # Stop impersonating
    click_button I18n.t("authenticated.impersonation_banner.stop")

    # Banner should be gone and admin session restored
    assert_no_selector "[data-testid='impersonation-banner']"
    assert_text I18n.t("admin.impersonations.stop.success")
  end
end
