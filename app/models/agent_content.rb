class AgentContent < ApplicationRecord
  include AccountScoped

  CONTENT_TYPES = %w[blog_post x_post linkedin_post research_report].freeze
  STATUSES = %w[draft pending_approval approved scheduled published rejected].freeze

  enum :content_type, CONTENT_TYPES.index_by(&:to_sym)
  enum :status, STATUSES.index_by(&:to_sym)

  validates :content_type, presence: true
  validates :status, presence: true
  validates :title, presence: true
  validates :body, presence: true
  validates :agent_name, presence: true

  serialize :metadata, coder: JSON

  scope :pending_approval, -> { where(status: :pending_approval) }
  scope :approved, -> { where(status: :approved) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :recent, -> { order(created_at: :desc) }

  def blog_post?
    content_type == "blog_post"
  end

  def x_post?
    content_type == "x_post"
  end

  def linkedin_post?
    content_type == "linkedin_post"
  end
end
