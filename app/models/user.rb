class User < ApplicationRecord
  # Built-in signed password reset token (no DB column needed).
  # Expires in 2 hours; auto-invalidates when password changes.
  has_secure_password reset_token: { expires_in: 2.hours }

  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :system_admins, -> { where(system_admin: true) }

  # Signed email verification token (no DB column needed).
  # Fingerprinted on email_verified_at — token is invalidated once the email is verified.
  generates_token_for :email_verification, expires_in: 30.days do
    email_verified_at
  end

  # Signed email change token (no DB column needed).
  # Fingerprinted on unconfirmed_email — token is invalidated once the change is confirmed.
  generates_token_for :email_change, expires_in: 24.hours do
    unconfirmed_email
  end

  def full_name
    [ first_name, last_name ].filter_map(&:presence).join(" ")
  end

  # Email verification
  def mark_email_verified!
    update!(email_verified_at: Time.current)
  end

  def email_verified?
    email_verified_at.present?
  end

  # Email change
  # Stores the new address and returns a signed change token.
  def generate_email_change_token!(new_email)
    update!(unconfirmed_email: new_email)
    generate_token_for(:email_change)
  end

  def confirm_email_change!
    update!(email: unconfirmed_email, unconfirmed_email: nil)
  end

  # Session token — rotated on password reset/change to invalidate other sessions.
  def generate_session_token!
    update!(session_token: SecureRandom.urlsafe_base64(32))
  end
end
