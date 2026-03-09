class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :body, null: false
      t.text :body_html
      t.datetime :published_at
      t.string :status, null: false, default: "draft"
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :posts, :slug, unique: true
    add_index :posts, :status
    add_index :posts, :published_at
  end
end
