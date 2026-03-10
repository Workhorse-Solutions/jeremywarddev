require "test_helper"

class AgentContentTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:acme)
    @other_account = accounts(:other)
    Current.account = @account
  end

  teardown do
    Current.account = nil
  end

  def build_content(attrs = {})
    AgentContent.new({
      account: @account,
      content_type: "blog_post",
      status: "pending_approval",
      title: "Test Content",
      body: "This is test content body.",
      agent_name: "Clark"
    }.merge(attrs))
  end

  # --- Account Scoping ---

  test "is account scoped" do
    content = build_content
    content.save!
    assert_equal @account, content.account
  end

  test "cannot access content from other accounts via Current.account scope" do
    other_content = agent_contents(:other_account_content)
    assert_equal @other_account, other_content.account

    assert_raises(ActiveRecord::RecordNotFound) do
      Current.account.agent_contents.find(other_content.id)
    end
  end

  test "for_current_account scope returns only current account content" do
    results = AgentContent.for_current_account
    results.each do |content|
      assert_equal @account.id, content.account_id
    end
  end

  # --- Validations ---

  test "requires account" do
    content = build_content(account: nil)
    assert_not content.valid?
    assert_includes content.errors[:account], "must exist"
  end

  test "requires content_type" do
    content = build_content(content_type: nil)
    assert_not content.valid?
    assert_includes content.errors[:content_type], "can't be blank"
  end

  test "requires title" do
    content = build_content(title: nil)
    assert_not content.valid?
    assert_includes content.errors[:title], "can't be blank"
  end

  test "requires body" do
    content = build_content(body: nil)
    assert_not content.valid?
    assert_includes content.errors[:body], "can't be blank"
  end

  test "requires agent_name" do
    content = build_content(agent_name: nil)
    assert_not content.valid?
    assert_includes content.errors[:agent_name], "can't be blank"
  end

  # --- Scopes ---

  test "pending_approval scope returns only pending content" do
    results = @account.agent_contents.pending_approval
    results.each do |content|
      assert_equal "pending_approval", content.status
    end
    assert results.any?
  end

  test "approved scope returns only approved content" do
    results = @account.agent_contents.approved
    results.each do |content|
      assert_equal "approved", content.status
    end
    assert results.any?
  end

  test "scheduled scope returns only scheduled content" do
    results = @account.agent_contents.scheduled
    results.each do |content|
      assert_equal "scheduled", content.status
    end
    assert results.any?
  end

  test "recent scope orders by created_at desc" do
    results = @account.agent_contents.recent
    dates = results.map(&:created_at)
    assert_equal dates.sort.reverse, dates
  end

  # --- Content type helpers ---

  test "blog_post? returns true for blog_post type" do
    content = build_content(content_type: "blog_post")
    assert content.blog_post?
  end

  test "x_post? returns true for x_post type" do
    content = build_content(content_type: "x_post")
    assert content.x_post?
  end

  test "linkedin_post? returns true for linkedin_post type" do
    content = build_content(content_type: "linkedin_post")
    assert content.linkedin_post?
  end

  # --- Status transitions ---

  test "can transition from pending_approval to approved" do
    content = agent_contents(:pending_blog)
    content.update!(status: :approved, approved_at: Time.current)
    assert_equal "approved", content.reload.status
  end

  test "can transition from pending_approval to rejected" do
    content = agent_contents(:pending_blog)
    content.update!(status: :rejected)
    assert_equal "rejected", content.reload.status
  end

  # --- Metadata ---

  test "metadata stores and retrieves JSON data" do
    content = build_content(metadata: { "word_count" => 500, "seo_keywords" => %w[rails ai] })
    content.save!
    content.reload
    assert_equal 500, content.metadata["word_count"]
    assert_equal %w[rails ai], content.metadata["seo_keywords"]
  end
end
