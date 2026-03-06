# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# =============================================================================
# Demo seed data — installed by rails generate rails_foundry_cli:demo
# Remove this section or run rails destroy rails_foundry_cli:demo to clean up.
# =============================================================================

# Owner: alice@example.com / password123
demo_owner = User.find_or_create_by!(email: "alice@example.com") do |u|
  u.password = "password123"
  u.first_name = "Alice"
  u.last_name = "Founder"
  u.email_verified_at = Time.current
end

# Account
demo_account = Account.find_or_create_by!(name: "Demo Company") do |a|
  a.billing_status = "trialing"
  a.trial_ends_at = 14.days.from_now
end

AccountUser.find_or_create_by!(account: demo_account, user: demo_owner) do |au|
  au.role = "owner"
end

# Team member: bob@example.com / password123
demo_member = User.find_or_create_by!(email: "bob@example.com") do |u|
  u.password = "password123"
  u.first_name = "Bob"
  u.last_name = "Member"
  u.email_verified_at = Time.current
end

AccountUser.find_or_create_by!(account: demo_account, user: demo_member) do |au|
  au.role = "member"
end

# Pending invitation
Invitation.find_or_create_by!(email: "charlie@example.com", account: demo_account) do |inv|
  inv.invited_by_user = demo_owner
  inv.expires_at = 7.days.from_now
end

puts "  Demo seed data loaded."
