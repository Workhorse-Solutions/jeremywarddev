class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :slug
      t.string :billing_status, null: false, default: "trialing"
      t.datetime :trial_ends_at
      t.string :stripe_customer_id
      t.string :stripe_subscription_id

      t.timestamps
    end

    add_index :accounts, :slug, unique: true
    add_index :accounts, :stripe_customer_id
    add_index :accounts, :stripe_subscription_id
  end
end
