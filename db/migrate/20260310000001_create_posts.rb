class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.text :body_html
      t.string :status, null: false, default: "draft"
      t.datetime :published_at

      t.timestamps
    end

    add_index :posts, [:account_id, :slug], unique: true
    add_index :posts, [:account_id, :status]
    add_index :posts, [:account_id, :published_at]
  end
end
