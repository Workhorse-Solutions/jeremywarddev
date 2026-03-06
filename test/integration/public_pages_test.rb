require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  test "GET / returns 200" do
    get root_path
    assert_response :ok
  end

  test "homepage renders placeholder with signup link" do
    get root_path
    assert_response :ok
    assert_includes response.body, signup_path
  end
end
