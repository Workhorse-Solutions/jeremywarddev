require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:acme)
    @other_account = accounts(:other)
    Current.account = @account
  end

  teardown do
    Current.account = nil
  end

  def build_post(attrs = {})
    Post.new({
      account: @account,
      title: "Hello World",
      body: "This is the body.",
      status: "draft"
    }.merge(attrs))
  end

  # --- Account Scoping ---

  test "is account scoped" do
    post = build_post
    post.save!
    assert_equal @account, post.account
  end

  test "cannot access posts from other accounts via Current.account scope" do
    other_post = posts(:other_account_post)
    assert_equal @other_account, other_post.account

    assert_raises(ActiveRecord::RecordNotFound) do
      Current.account.posts.find(other_post.id)
    end
  end

  test "for_current_account scope returns only current account posts" do
    acme_posts = Post.for_current_account
    acme_posts.each do |post|
      assert_equal @account.id, post.account_id
    end
  end

  test "for_current_account raises when Current.account is nil" do
    Current.account = nil
    assert_raises(AccountScoped::CurrentAccountNotSet) do
      Post.for_current_account.to_a
    end
  end

  # --- Validations ---

  test "valid with required attributes" do
    post = build_post
    assert post.valid?
  end

  test "invalid without account" do
    post = build_post(account: nil)
    assert_not post.valid?
    assert post.errors[:account].any?
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

  test "invalid with non-unique slug within same account" do
    build_post(title: "First", slug: "first-post").save!
    duplicate = build_post(title: "Second", slug: "first-post")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "allows same slug across different accounts" do
    build_post(account: @account, title: "First", slug: "shared-slug").save!
    other = build_post(account: @other_account, title: "Second", slug: "shared-slug")
    assert other.valid?
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

  test "scheduled status requires published_at" do
    post = build_post(status: "scheduled", published_at: nil)
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

  test "slug generation handles uniqueness within account by appending counter" do
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
    draft_post = build_post(title: "Draft", slug: "my-draft", status: "draft")
    draft_post.save!

    published = @account.posts.published
    assert_includes published, past_post
    assert_not_includes published, future_post
    assert_not_includes published, draft_post
  end

  test "draft scope returns only draft posts" do
    draft = build_post(title: "Draft", slug: "my-draft", status: "draft")
    draft.save!
    published = build_post(title: "Pub", slug: "pub-post", status: "published", published_at: 1.day.ago)
    published.save!

    drafts = @account.posts.draft
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
