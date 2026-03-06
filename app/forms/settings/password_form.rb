class Settings::PasswordForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :current_password, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  validates :current_password, presence: true
  validates :password, presence: true, length: { minimum: 8 }, confirmation: true
  validates :password_confirmation, presence: true

  validate :current_password_correct, if: -> { current_password.present? }

  attr_accessor :user

  def save
    return false unless valid?

    user.update!(password: password, password_confirmation: password_confirmation)
    user.generate_session_token!
    true
  end

  private

  def current_password_correct
    unless user&.authenticate(current_password)
      errors.add(:current_password, "is incorrect")
    end
  end
end
