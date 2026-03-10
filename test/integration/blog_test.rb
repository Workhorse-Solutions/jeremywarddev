require "test_helper"

class BlogTest < ActionDispatch::IntegrationTest
  setup do
    @published_post = posts(:published_post)
    @draft_post = posts(:draft_post)
    @other_post = posts(:other_account_post)
  end

  # --- Public Blog ---

  test "GET /blog returns 200 and shows published posts" do
    get blog_path
    assert_response :ok
    assert_includes response.body, @published_post.title
  end

  test "GET /blog does not show draft posts" do
    get blog_path
    assert_response :ok
    assert_not_includes response.body, @draft_post.title
  end

  test "GET /blog does not show posts from other accounts" do
    get blog_path
    assert_response :ok
    assert_not_includes response.body, @other_post.title
  end

  test "GET /blog/:slug returns 200 for published post" do
    get blog_post_path(slug: @published_post.slug)
    assert_response :ok
    assert_includes response.body, @published_post.title
  end

  test "GET /blog/:slug returns 404 for draft post" do
    get blog_post_path(slug: @draft_post.slug)
    assert_response :not_found
  end

  test "GET /blog/:slug returns 404 for other account post" do
    get blog_post_path(slug: @other_post.slug)
    assert_response :not_found
  end

  test "GET /blog/feed.rss returns RSS feed" do
    get blog_feed_path(format: :rss)
    assert_response :ok
    assert_includes response.content_type, "application/rss+xml"
    assert_includes response.body, @published_post.title
  end

  test "RSS feed excludes other account posts" do
    get blog_feed_path(format: :rss)
    assert_response :ok
    assert_not_includes response.body, @other_post.title
  end
end
