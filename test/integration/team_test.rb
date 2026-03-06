require "test_helper"

class TeamTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:alice)
    @bob = users(:admin_bob)
    @carol = users(:member_carol)
  end

  test "GET /team returns 200 for authenticated owner" do
    sign_in_as @alice
    get team_path
    assert_response :ok
  end

  test "GET /team returns 200 for authenticated admin" do
    sign_in_as @bob
    get team_path
    assert_response :ok
  end

  test "GET /team returns 200 for authenticated member" do
    sign_in_as @carol
    get team_path
    assert_response :ok
  end

  test "GET /team redirects to login when unauthenticated" do
    get team_path
    assert_redirected_to login_path
  end

  test "GET /team lists all account members with names, emails, and roles" do
    sign_in_as @alice
    get team_path

    assert_select "[data-testid='team-member-row']", count: 3
    assert_select "td", text: @alice.full_name
    assert_select "td", text: @alice.email
    assert_select "td", text: @bob.full_name
    assert_select "td", text: @carol.full_name
    assert_select "span.badge", text: "owner"
    assert_select "span.badge", text: "admin"
    assert_select "span.badge", text: "member"
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
