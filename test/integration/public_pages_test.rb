require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  test "GET / returns 200" do
    get root_path
    assert_response :ok
  end

  test "homepage renders hero and portfolio link" do
    get root_path
    assert_response :ok
    assert_includes response.body, portfolio_path
  end
end
