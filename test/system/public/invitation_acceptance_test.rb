require_relative "../application_system_test_case"

class Public::InvitationAcceptanceSystemTest < ApplicationSystemTestCase
  setup do
    @invitation = invitations(:pending_invite)
    @token = @invitation.generate_token_for(:acceptance)
  end

  test "existing user accepts invitation via login flow and lands on dashboard" do
    User.create!(email: "pending@example.com", password: "password", password_confirmation: "password")

    # Visit invitation page (unauthenticated) and click accept
    visit invitation_path(token: @token)
    click_button I18n.t("public.invitations.show.accept_button")

    # Redirected to login since user exists but is not logged in
    assert_text I18n.t("public.invitations.login_to_accept")

    # Sign in
    fill_in "Email", with: "pending@example.com"
    fill_in "Password", with: "password"
    click_button I18n.t("public.sessions.new.submit")

    # Redirected back to invitation page — accept
    click_button I18n.t("public.invitations.show.accept_button")

    assert_text I18n.t("public.invitations.accepted")
    assert_current_path dashboard_path
  end

  test "invitation no longer appears as pending after acceptance" do
    User.create!(email: "pending@example.com", password: "password", password_confirmation: "password")

    # Accept invitation via login flow
    visit invitation_path(token: @token)
    click_button I18n.t("public.invitations.show.accept_button")

    fill_in "Email", with: "pending@example.com"
    fill_in "Password", with: "password"
    click_button I18n.t("public.sessions.new.submit")
    click_button I18n.t("public.invitations.show.accept_button")

    assert_current_path dashboard_path

    # Sign out and check as owner
    page.driver.submit :delete, logout_path, {}

    sign_in_as users(:alice)
    visit team_path

    assert_no_selector "[data-testid='pending-invitation-row']", text: "pending@example.com"
  end
end
