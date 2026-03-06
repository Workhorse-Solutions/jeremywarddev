class Invitation < ApplicationRecord
  include AccountScoped

  belongs_to :invited_by_user, class_name: "User"

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  generates_token_for :acceptance, expires_in: 7.days do
    accepted_at.to_s
  end

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }

  def accepted?
    accepted_at.present?
  end

  def expired?
    expires_at <= Time.current
  end

  def accept!(user)
    transaction do
      update!(accepted_at: Time.current)
      AccountUser.create!(account: account, user: user, role: "member")
    end
  end
end
