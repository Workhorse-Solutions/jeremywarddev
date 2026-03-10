class CreateAgentContents < ActiveRecord::Migration[8.0]
  def change
    create_table :agent_contents do |t|
      t.references :account, null: false, foreign_key: true
      t.string :content_type, null: false
      t.string :status, null: false, default: "pending_approval"
      t.string :title, null: false
      t.text :body, null: false
      t.text :metadata
      t.string :agent_name, null: false
      t.datetime :approved_at
      t.datetime :published_at
      t.datetime :scheduled_for

      t.timestamps
    end

    add_index :agent_contents, [:account_id, :status]
    add_index :agent_contents, [:account_id, :content_type]
    add_index :agent_contents, [:account_id, :created_at]
  end
end
