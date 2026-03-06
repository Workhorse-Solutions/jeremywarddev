class RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, confirmation: true
  validates :password_confirmation, presence: true

  validate :email_uniqueness, if: -> { email.present? && errors[:email].empty? }

  attr_reader :user, :account

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      @user = User.create!(
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        first_name: first_name,
        last_name: last_name
      )

      @account = Account.create!(
        name: derive_account_name,
        billing_status: "trialing",
        trial_ends_at: 14.days.from_now
      )

      AccountUser.create!(
        user: @user,
        account: @account,
        role: "owner"
      )
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
    false
  end

  private

  def email_uniqueness
    if User.exists?(email: email)
      errors.add(:email, "is not available")
    end
  end

  def derive_account_name
    domain = email.to_s.split("@").last.to_s
    domain.split(".").first.to_s.capitalize.presence || "My Account"
  end
end
