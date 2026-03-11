class Post < ApplicationRecord
  include AccountScoped

  STATUSES = %w[draft scheduled published].freeze

  # Validations
  validates :title, presence: true
  validates :body, presence: true
  validates :slug, presence: true, uniqueness: { scope: :account_id }
  validates :slug, format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }
  validates :status, inclusion: { in: STATUSES }
  validates :published_at, presence: true, if: -> { published? || scheduled? }

  # Scopes
  scope :published, -> { where(status: "published").where("published_at <= ?", Time.current) }
  scope :scheduled, -> { where(status: "scheduled").or(where(status: "published").where("published_at > ?", Time.current)) }
  scope :draft, -> { where(status: "draft") }
  scope :recent, -> { order(published_at: :desc) }

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && title.present? }
  before_save :render_markdown
  before_save :sync_status

  def published?
    status == "published"
  end

  def scheduled?
    status == "scheduled"
  end

  def draft?
    status == "draft"
  end

  def live?
    published? && published_at <= Time.current
  end

  private

  def generate_slug
    base_slug = title.downcase.gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-").gsub(/-+/, "-").strip.chomp("-")
    self.slug = base_slug

    # Ensure uniqueness within account
    counter = 1
    while Post.where(account: account, slug: slug).where.not(id: id).exists?
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def render_markdown
    return unless body_changed?

    renderer = MarkdownRenderer.new(filter_html: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true
    )
    self.body_html = markdown.render(body)
  end

  def sync_status
    return unless published_at.present?

    if status == "published" && published_at > Time.current
      self.status = "scheduled"
    elsif status == "scheduled" && published_at <= Time.current
      self.status = "published"
    end
  end
end
