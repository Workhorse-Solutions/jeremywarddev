require "test_helper"

class Admin::ContentTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_bob)
    @account = accounts(:acme)
    @pending = agent_contents(:pending_blog)
    @approved = agent_contents(:approved_linkedin)
    @scheduled = agent_contents(:scheduled_tweet)
    @other_content = agent_contents(:other_account_content)

    # Log in as admin
    post login_path, params: { email: @admin.email, password: "password" }
  end

  # --- Index ---

  test "GET /admin/content returns 200 for admin" do
    get admin_content_index_path
    assert_response :ok
    assert_includes response.body, @pending.title
  end

  test "GET /admin/content does not show other account content" do
    get admin_content_index_path
    assert_response :ok
    assert_not_includes response.body, @other_content.title
  end

  test "GET /admin/content shows pending, approved, and scheduled sections" do
    get admin_content_index_path
    assert_response :ok
    assert_includes response.body, "Pending Approval"
    assert_includes response.body, "Recently Approved"
    assert_includes response.body, "Scheduled"
  end

  # --- Show ---

  test "GET /admin/content/:id returns 200 for own content" do
    get admin_content_path(@pending)
    assert_response :ok
    assert_includes response.body, @pending.title
  end

  test "GET /admin/content/:id returns 404 for other account content" do
    get admin_content_path(@other_content)
    assert_response :not_found
  end

  # --- Edit / Update ---

  test "GET /admin/content/:id/edit returns 200" do
    get edit_admin_content_path(@pending)
    assert_response :ok
  end

  test "PATCH /admin/content/:id updates content" do
    patch admin_content_path(@pending), params: {
      agent_content: { title: "Updated Title" }
    }
    assert_redirected_to admin_content_path(@pending)
    @pending.reload
    assert_equal "Updated Title", @pending.title
  end

  test "PATCH /admin/content/:id scoped to current account" do
    patch admin_content_path(@other_content), params: {
      agent_content: { title: "Hacked Title" }
    }
    assert_response :not_found
    @other_content.reload
    assert_not_equal "Hacked Title", @other_content.title
  end

  # --- Approve ---

  test "POST /admin/content/:id/approve approves content" do
    post approve_admin_content_path(@pending)
    assert_redirected_to admin_content_index_path
    @pending.reload
    assert_includes %w[approved published], @pending.status
    assert_not_nil @pending.approved_at
  end

  test "POST /admin/content/:id/approve creates Post for blog_post" do
    assert_difference "Post.count", 1 do
      post approve_admin_content_path(@pending)
    end
    new_post = Post.order(created_at: :desc).first
    assert_equal @account.id, new_post.account_id
    assert_equal @pending.title, new_post.title
    assert_equal @pending.body, new_post.body

    @pending.reload
    assert_equal "published", @pending.status
    assert_not_nil @pending.published_at
  end

  test "POST /admin/content/:id/approve does not create Post for non-blog content" do
    assert_no_difference "Post.count" do
      post approve_admin_content_path(@approved.tap { |c| c.update!(status: :pending_approval) })
    end
  end

  test "POST /admin/content/:id/approve returns 404 for other account" do
    post approve_admin_content_path(@other_content)
    assert_response :not_found
  end

  # --- Reject ---

  test "POST /admin/content/:id/reject rejects content" do
    post reject_admin_content_path(@pending), params: { note: "Needs revision" }
    assert_redirected_to admin_content_index_path
    @pending.reload
    assert_equal "rejected", @pending.status
    assert_equal "Needs revision", @pending.metadata["rejection_note"]
  end

  test "POST /admin/content/:id/reject returns 404 for other account" do
    post reject_admin_content_path(@other_content)
    assert_response :not_found
  end

  # --- Destroy ---

  test "DELETE /admin/content/:id destroys content" do
    assert_difference "AgentContent.count", -1 do
      delete admin_content_path(@pending)
    end
    assert_redirected_to admin_content_index_path
  end

  test "DELETE /admin/content/:id returns 404 for other account" do
    assert_no_difference "AgentContent.count" do
      delete admin_content_path(@other_content)
    end
    assert_response :not_found
  end
end
