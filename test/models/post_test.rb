require "test_helper"

class PostTest < ActiveSupport::TestCase
  def build_post(attrs = {})
    Post.new({
      title: "Hello World",
      body: "This is the body.",
      status: "draft"
    }.merge(attrs))
  end

  # --- Validations ---

  test "valid with required attributes" do
    post = build_post
    assert post.valid?
  end

  test "invalid without title" do
    post = build_post(title: nil)
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "invalid without body" do
    post = build_post(body: nil)
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "invalid with bad slug format" do
    post = build_post(slug: "Bad Slug!")
    assert_not post.valid?
    assert post.errors[:slug].any?
  end

  test "invalid with non-unique slug" do
    existing = build_post(title: "First", slug: "first-post")
    existing.save!
    duplicate = build_post(title: "Second", slug: "first-post")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "invalid with unknown status" do
    post = build_post(status: "unknown")
    assert_not post.valid?
  end

  test "published status requires published_at" do
    post = build_post(status: "published", published_at: nil)
    assert_not post.valid?
    assert post.errors[:published_at].any?
  end

  # --- Slug auto-generation ---

  test "generates slug from title before validation" do
    post = build_post(title: "Hello World", slug: nil)
    post.valid?
    assert_equal "hello-world", post.slug
  end

  test "slug generation strips special characters" do
    post = build_post(title: "Hello, World! (Test)", slug: nil)
    post.valid?
    assert_match(/\A[a-z0-9-]+\z/, post.slug)
  end

  test "slug generation handles uniqueness by appending counter" do
    first = build_post(title: "hello world", slug: nil)
    first.save!
    second = build_post(title: "hello world", slug: nil)
    second.valid?
    assert_not_equal first.slug, second.slug
    assert second.slug.start_with?("hello-world-")
  end

  # --- Scopes ---

  test "published scope returns only published posts with past published_at" do
    past_post = build_post(status: "published", published_at: 1.day.ago)
    past_post.save!
    future_post = build_post(title: "Future", slug: "future", status: "published", published_at: 1.day.from_now)
    future_post.save!
    draft_post = build_post(title: "Draft", slug: "draft-post", status: "draft")
    draft_post.save!

    published = Post.published
    assert_includes published, past_post
    assert_not_includes published, future_post
    assert_not_includes published, draft_post
  end

  test "draft scope returns only draft posts" do
    draft = build_post(title: "Draft", slug: "my-draft", status: "draft")
    draft.save!
    published = build_post(title: "Pub", slug: "pub-post", status: "published", published_at: 1.day.ago)
    published.save!

    drafts = Post.draft
    assert_includes drafts, draft
    assert_not_includes drafts, published
  end

  # --- Markdown rendering ---

  test "renders body markdown to body_html before save" do
    post = build_post(body: "# Hello\n\nThis is **bold**.")
    post.save!
    assert_includes post.body_html, "<h1>"
    assert_includes post.body_html, "<strong>bold</strong>"
  end

  test "renders fenced code blocks with syntax highlighting" do
    post = build_post(body: "```ruby\nputs 'hello'\n```")
    post.save!
    assert_includes post.body_html, "<pre"
    assert_includes post.body_html, "code"
  end

  # --- Status sync ---

  test "syncs status to scheduled when published_at is in the future" do
    post = build_post(status: "published", published_at: 1.day.from_now)
    post.save!
    assert_equal "scheduled", post.status
  end

  test "syncs status to published when scheduled and published_at is past" do
    post = build_post(status: "scheduled", published_at: 1.day.ago)
    post.save!
    assert_equal "published", post.status
  end

  # --- Predicates ---

  test "live? returns true for published post with past published_at" do
    post = build_post(status: "published", published_at: 1.day.ago)
    post.save!
    assert post.live?
  end

  test "live? returns false for draft post" do
    post = build_post(status: "draft")
    post.save!
    assert_not post.live?
  end
end
