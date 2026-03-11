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
# Site owner
# =============================================================================

owner = User.find_or_create_by!(email: "jeremy@workhorsesolutions.llc") do |u|
  u.password = ENV.fetch("ADMIN_PASSWORD") { SecureRandom.hex(16) }
  u.first_name = "Jeremy"
  u.last_name = "Ward"
  u.email_verified_at = Time.current
  u.system_admin = true
end

account = Account.find_or_create_by!(name: "Jeremy Ward") do |a|
  a.billing_status = "active"
end

AccountUser.find_or_create_by!(account: account, user: owner) do |au|
  au.role = "owner"
end

# Ensure system_admin is set even if user already existed
owner.update!(system_admin: true) unless owner.system_admin?

puts "  Site owner seeded (jeremy@workhorsesolutions.llc)."
