class Subscriber < ApplicationRecord
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, length: { maximum: 100 }

  normalizes :email, with: ->(email) { email.strip.downcase }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
end
