class AccountUser < ApplicationRecord
  ROLES = %w[owner admin member].freeze

  belongs_to :account
  belongs_to :user

  validates :role, inclusion: { in: ROLES }

  def can_manage_members?
    role.in?(%w[owner admin])
  end

  def last_owner?
    role == "owner" && account.account_users.where(role: "owner").count == 1
  end
end
