class Settings::AccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :slug, :string

  validates :name, presence: true
  validates :slug,
    format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" },
    allow_blank: true

  attr_accessor :account

  def save
    return false unless valid?

    account.update(name: name, slug: slug.presence)
  end
end
