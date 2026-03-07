# Reads markdown files from content/blog/ directory.
# No database needed — files are the source of truth.
#
# File format: YYYY-MM-DD-slug.md
# Front matter (YAML between --- delimiters):
#   title: Post Title
#   date: 2024-01-15
#   tags: [rails, saas]
#   excerpt: Short description
#   published: true
#
class BlogPost
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :slug, :string
  attribute :date, :date
  attribute :tags, default: []
  attribute :excerpt, :string
  attribute :body, :string
  attribute :published, :boolean, default: true

  CONTENT_DIR = Rails.root.join("content", "blog")

  class << self
    def all_published
      all_posts.select(&:published?).sort_by(&:date).reverse
    end

    def recent(limit = 3)
      all_published.first(limit)
    end

    def find_by_slug!(slug)
      post = all_posts.find { |p| p.slug == slug }
      raise ActiveRecord::RecordNotFound, "Blog post '#{slug}' not found" unless post
      post
    end

    def all_posts
      @all_posts = nil if Rails.env.development? # Reload in dev
      @all_posts ||= load_all_posts
    end

    private

    def load_all_posts
      Dir.glob(CONTENT_DIR.join("*.md")).map do |file|
        parse_file(file)
      end.compact
    end

    def parse_file(file_path)
      content = File.read(file_path)
      return nil unless content.start_with?("---")

      parts = content.split("---", 3)
      return nil if parts.length < 3

      front_matter = YAML.safe_load(parts[1], permitted_classes: [ Date, Time ])
      body_markdown = parts[2].strip

      # Extract slug from filename: 2024-01-15-my-post-title.md -> my-post-title
      filename = File.basename(file_path, ".md")
      slug = filename.sub(/^\d{4}-\d{2}-\d{2}-/, "")

      new(
        title: front_matter["title"],
        slug: slug,
        date: front_matter["date"],
        tags: Array(front_matter["tags"]),
        excerpt: front_matter["excerpt"],
        body: render_markdown(body_markdown),
        published: front_matter.fetch("published", true)
      )
    rescue => e
      Rails.logger.error "Error parsing blog post #{file_path}: #{e.message}"
      nil
    end

    def render_markdown(text)
      renderer = RougeRenderer.new(hard_wrap: true, link_attributes: { target: "_blank", rel: "noopener" })
      markdown = Redcarpet::Markdown.new(
        renderer,
        fenced_code_blocks: true,
        autolink: true,
        tables: true,
        strikethrough: true,
        highlight: true,
        footnotes: true
      )
      markdown.render(text).html_safe
    end
  end

  def published?
    published
  end

  def reading_time
    words = body.to_s.split.size
    minutes = (words / 200.0).ceil
    "#{minutes} min read"
  end

  def formatted_date
    date&.strftime("%B %d, %Y")
  end
end
