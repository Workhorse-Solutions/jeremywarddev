class EmailChangeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :new_email, :string
  attribute :current_password, :string

  validates :new_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :current_password, presence: true

  validate :current_password_correct, if: -> { current_password.present? }
  validate :email_uniqueness, if: -> { new_email.present? && errors[:new_email].empty? }

  attr_accessor :user

  def save
    return false unless valid?

    user.generate_email_change_token!(new_email)
    UserMailer.email_change_confirmation(user).deliver_later

    true
  end

  private

  def current_password_correct
    unless user&.authenticate(current_password)
      errors.add(:current_password, :invalid)
    end
  end

  def email_uniqueness
    if User.where.not(id: user&.id).exists?(email: new_email)
      errors.add(:new_email, "is already taken")
    end
  end
end
