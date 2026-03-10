require "test_helper"

class Admin::PostsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_bob)
    @account = accounts(:acme)
    @post = posts(:published_post)
    @other_post = posts(:other_account_post)

    # Log in as admin
    post login_path, params: { email: @admin.email, password: "password" }
  end

  test "GET /admin/posts returns 200 for admin" do
    get admin_posts_path
    assert_response :ok
    assert_includes response.body, @post.title
  end

  test "GET /admin/posts does not show other account posts" do
    get admin_posts_path
    assert_response :ok
    assert_not_includes response.body, @other_post.title
  end

  test "GET /admin/posts/new returns 200" do
    get new_admin_post_path
    assert_response :ok
  end

  test "POST /admin/posts creates a post scoped to current account" do
    assert_difference "Post.count" do
      post admin_posts_path, params: {
        post: { title: "New Post", body: "Content", status: "draft" }
      }
    end
    new_post = Post.order(created_at: :desc).first
    assert_equal @account.id, new_post.account_id
    assert_redirected_to admin_post_path(new_post)
  end

  test "GET /admin/posts/:id returns 200 for own post" do
    get admin_post_path(@post)
    assert_response :ok
  end

  test "GET /admin/posts/:id returns 404 for other account post" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get admin_post_path(@other_post)
    end
  end

  test "PATCH /admin/posts/:id updates post" do
    patch admin_post_path(@post), params: {
      post: { title: "Updated Title" }
    }
    assert_redirected_to admin_post_path(@post)
    @post.reload
    assert_equal "Updated Title", @post.title
  end

  test "DELETE /admin/posts/:id destroys post" do
    assert_difference "Post.count", -1 do
      delete admin_post_path(@post)
    end
    assert_redirected_to admin_posts_path
  end

  test "cannot update other account post" do
    assert_raises(ActiveRecord::RecordNotFound) do
      patch admin_post_path(@other_post), params: {
        post: { title: "Hacked" }
      }
    end
  end

  test "cannot destroy other account post" do
    assert_raises(ActiveRecord::RecordNotFound) do
      delete admin_post_path(@other_post)
    end
  end
end
