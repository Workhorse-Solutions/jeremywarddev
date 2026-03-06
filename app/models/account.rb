class Account < ApplicationRecord
  BILLING_STATUSES = %w[trialing active past_due canceled].freeze

  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :invitations, dependent: :destroy

  validates :name, presence: true
  validates :billing_status, inclusion: { in: BILLING_STATUSES }
end
