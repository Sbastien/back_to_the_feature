# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default admin user
admin_user = User.find_or_create_by!(username: "admin") do |user|
  user.password = "password"
  user.role = "admin"
end

puts "✅ Default admin user created: #{admin_user.username}"

# Create example groups for external service
example_groups = [
  {
    name: "beta_testers",
    definition: 'email.ends_with? "@example.com"'
  },
  {
    name: "premium_users",
    definition: 'role == "premium"'
  },
  {
    name: "us_users",
    definition: 'country == "US"'
  }
]

example_groups.each do |group_attrs|
  group = Group.find_or_create_by!(name: group_attrs[:name]) do |g|
    g.definition = group_attrs[:definition]
  end
  puts "✅ Group created: #{group.name}"
end

# Create example flag
example_flag = Flag.find_or_create_by!(name: "new_dashboard") do |flag|
  flag.description = "New dashboard design with improved UX"
  flag.variants = [
    { "name" => "old", "weight" => 70 },
    { "name" => "new", "weight" => 30 }
  ]
end

puts "✅ Example flag created: #{example_flag.name}"

# Create example rules for the flag
Rule.find_or_create_by!(flag: example_flag, type: "group", value: "beta_testers")
Rule.find_or_create_by!(flag: example_flag, type: "percentage_of_actors", value: "10")

puts "✅ Example rules created for #{example_flag.name}"

puts "🎉 Database seeded successfully!"
puts "📝 You can login with: admin / password"
