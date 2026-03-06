class AddAuthTokensToUsers < ActiveRecord::Migration[8.1]
  def change
    # Token columns for password reset and email verification/change are NOT
    # stored in the DB — Rails generates signed tokens via has_secure_password
    # (reset_token:) and generates_token_for, which require no DB columns.
    add_column :users, :email_verified_at, :datetime
    add_column :users, :unconfirmed_email, :string  # pending email during change flow
    add_column :users, :session_token, :string
    add_index :users, :session_token, unique: true
  end
end
