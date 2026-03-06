class InvitationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validate :not_already_a_member, if: -> { email.present? && errors[:email].empty? }
  validate :no_pending_invitation, if: -> { email.present? && errors[:email].empty? }

  attr_reader :invitation

  def initialize(account:, invited_by:, **attributes)
    @account = account
    @invited_by = invited_by
    super(**attributes)
  end

  def save
    return false unless valid?

    @invitation = Invitation.create!(
      account: @account,
      invited_by_user: @invited_by,
      email: email.downcase.strip,
      expires_at: 7.days.from_now
    )

    InvitationMailer.invite_email(@invitation).deliver_later

    true
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
    false
  end

  private

  def not_already_a_member
    normalized = email.downcase.strip
    if @account.users.exists?(email: normalized)
      errors.add(:email, :already_a_member)
    end
  end

  def no_pending_invitation
    normalized = email.downcase.strip
    if @account.invitations.pending.exists?(email: normalized)
      errors.add(:email, :invitation_pending)
    end
  end
end
