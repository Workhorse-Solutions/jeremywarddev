module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account

    validates :account, presence: true

    scope :for_account, ->(account) { where(account: account) }

    scope :for_current_account, -> {
      raise AccountScoped::CurrentAccountNotSet, "Current.account is not set" unless Current.account

      where(account: Current.account)
    }
  end

  class CurrentAccountNotSet < StandardError; end
end
