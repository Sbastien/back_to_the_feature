# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting database seed..."
puts

# Create admin users
admin_users = [
  { username: "admin", password: "password", role: "admin" },
  { username: "superadmin", password: "supersecret", role: "admin" },
  { username: "devops", password: "devops123", role: "admin" }
]

admin_users.each do |user_attrs|
  user = User.find_or_create_by!(username: user_attrs[:username]) do |u|
    u.password = user_attrs[:password]
    u.role = user_attrs[:role]
  end
  puts "👑 Admin user created: #{user.username}"
end

# Create regular users
regular_users = [
  { username: "alice", password: "alice123" },
  { username: "bob", password: "bob123" },
  { username: "charlie", password: "charlie123" },
  { username: "diana", password: "diana123" },
  { username: "eve", password: "eve123" },
  { username: "frank", password: "frank123" },
  { username: "grace", password: "grace123" },
  { username: "henry", password: "henry123" },
  { username: "iris", password: "iris123" },
  { username: "jack", password: "jack123" }
]

regular_users.each do |user_attrs|
  user = User.find_or_create_by!(username: user_attrs[:username]) do |u|
    u.password = user_attrs[:password]
    u.role = "user"
  end
  puts "👤 Regular user created: #{user.username}"
end

puts

# Create diverse groups for targeting
groups_data = [
  # Geographic groups
  {
    name: "us_users",
    definition: "country == 'US'"
  },
  {
    name: "eu_users",
    definition: "contains(['FR', 'DE', 'IT', 'ES', 'UK'], country)"
  },
  {
    name: "asia_pacific",
    definition: "contains(['JP', 'AU', 'SG', 'KR'], country)"
  },

  # User tier groups
  {
    name: "beta_testers",
    definition: "ends_with(email, '@example.com')"
  },
  {
    name: "premium_users",
    definition: "subscription == 'premium'"
  },
  {
    name: "enterprise_users",
    definition: "subscription == 'enterprise'"
  },
  {
    name: "free_tier_users",
    definition: "subscription == 'free'"
  },

  # Behavioral groups
  {
    name: "active_users",
    definition: "status == 'active'"
  },
  {
    name: "power_users",
    definition: "subscription == 'premium'"
  },
  {
    name: "mobile_users",
    definition: "device_type == 'mobile'"
  },
  {
    name: "desktop_users",
    definition: "device_type == 'desktop'"
  },

  # Admin groups
  {
    name: "internal_staff",
    definition: "ends_with(email, '@company.com')"
  },
  {
    name: "support_team",
    definition: "role == 'support'"
  },

  # Testing groups
  {
    name: "qa_testers",
    definition: "starts_with(username, 'qa_')"
  },
  {
    name: "canary_users",
    definition: "role == 'beta'"
  }
]

groups_data.each do |group_attrs|
  group = Group.find_or_create_by!(name: group_attrs[:name]) do |g|
    g.definition = group_attrs[:definition]
  end
  puts "🎯 Group created: #{group.name}"
end

puts

# Create feature flags
flags_data = [
  {
    name: "new_dashboard",
    description: "New dashboard design with improved UX and analytics",
    enabled: true
  },
  {
    name: "dark_mode",
    description: "Dark theme option for better user experience",
    enabled: true
  },
  {
    name: "advanced_search",
    description: "Enhanced search functionality with filters and faceted search",
    enabled: false
  },
  {
    name: "real_time_notifications",
    description: "WebSocket-based real-time notifications system",
    enabled: true
  },
  {
    name: "mobile_app_redesign",
    description: "Complete mobile application UI/UX overhaul",
    enabled: false
  },
  {
    name: "ai_recommendations",
    description: "Machine learning powered content recommendations",
    enabled: true
  },
  {
    name: "payment_gateway_v2",
    description: "New payment processing system with multiple providers",
    enabled: false
  },
  {
    name: "social_login",
    description: "OAuth integration with Google, GitHub, and LinkedIn",
    enabled: true
  },
  {
    name: "performance_monitoring",
    description: "Enhanced application performance monitoring and alerts",
    enabled: true
  },
  {
    name: "beta_api_v3",
    description: "Next generation API with GraphQL support",
    enabled: false
  },
  {
    name: "audit_logging",
    description: "Comprehensive audit trail for all user actions",
    enabled: true
  },
  {
    name: "multi_language_support",
    description: "Internationalization with 10+ language support",
    enabled: false
  }
]

created_flags = []
flags_data.each do |flag_attrs|
  flag = Flag.find_or_create_by!(name: flag_attrs[:name]) do |f|
    f.description = flag_attrs[:description]
    f.enabled = flag_attrs[:enabled]
  end
  created_flags << flag
  puts "🚩 Feature flag created: #{flag.name} (#{flag.enabled? ? 'enabled' : 'disabled'})"
end

# Create rules for feature flags
rules_data = [
  # New Dashboard - gradual rollout
  { flag_name: "new_dashboard", type: "group", value: "beta_testers" },
  { flag_name: "new_dashboard", type: "group", value: "internal_staff" },
  { flag_name: "new_dashboard", type: "percentage_of_actors", value: "25" },

  # Dark Mode - available to all active users
  { flag_name: "dark_mode", type: "group", value: "active_users" },
  { flag_name: "dark_mode", type: "percentage_of_actors", value: "100" },

  # Advanced Search - only for premium users
  { flag_name: "advanced_search", type: "group", value: "premium_users" },
  { flag_name: "advanced_search", type: "group", value: "enterprise_users" },

  # Real-time Notifications - mobile and power users
  { flag_name: "real_time_notifications", type: "group", value: "mobile_users" },
  { flag_name: "real_time_notifications", type: "group", value: "power_users" },
  { flag_name: "real_time_notifications", type: "percentage_of_actors", value: "50" },

  # Mobile App Redesign - canary release
  { flag_name: "mobile_app_redesign", type: "group", value: "canary_users" },
  { flag_name: "mobile_app_redesign", type: "group", value: "qa_testers" },

  # AI Recommendations - geographic rollout
  { flag_name: "ai_recommendations", type: "group", value: "us_users" },
  { flag_name: "ai_recommendations", type: "group", value: "premium_users" },
  { flag_name: "ai_recommendations", type: "percentage_of_actors", value: "30" },

  # Payment Gateway V2 - careful rollout
  { flag_name: "payment_gateway_v2", type: "group", value: "internal_staff" },
  { flag_name: "payment_gateway_v2", type: "group", value: "enterprise_users" },
  { flag_name: "payment_gateway_v2", type: "percentage_of_actors", value: "5" },

  # Social Login - wide availability
  { flag_name: "social_login", type: "group", value: "free_tier_users" },
  { flag_name: "social_login", type: "percentage_of_actors", value: "80" },

  # Performance Monitoring - admin and power users
  { flag_name: "performance_monitoring", type: "group", value: "internal_staff" },
  { flag_name: "performance_monitoring", type: "group", value: "support_team" },
  { flag_name: "performance_monitoring", type: "group", value: "power_users" },

  # Beta API V3 - developers and internal
  { flag_name: "beta_api_v3", type: "group", value: "internal_staff" },
  { flag_name: "beta_api_v3", type: "group", value: "beta_testers" },
  { flag_name: "beta_api_v3", type: "percentage_of_actors", value: "10" },

  # Audit Logging - compliance and enterprise
  { flag_name: "audit_logging", type: "group", value: "enterprise_users" },
  { flag_name: "audit_logging", type: "group", value: "internal_staff" },
  { flag_name: "audit_logging", type: "percentage_of_actors", value: "15" },

  # Multi-language Support - international rollout
  { flag_name: "multi_language_support", type: "group", value: "eu_users" },
  { flag_name: "multi_language_support", type: "group", value: "asia_pacific" },
  { flag_name: "multi_language_support", type: "percentage_of_actors", value: "20" }
]

rules_created = 0
created_flags.each do |flag|
  flag_rules = rules_data.select { |rule| rule[:flag_name] == flag.name }
  flag_rules.each do |rule_attrs|
    rule = Rule.find_or_create_by!(
      flag: flag,
      type: rule_attrs[:type],
      value: rule_attrs[:value]
    )
    rules_created += 1
  end
  puts "📋 Rules created for #{flag.name}: #{flag_rules.size} rules"
end

puts
puts "🎉 Database seeded successfully!"
puts "📊 Summary:"
puts "   👑 #{admin_users.size} admin users created"
puts "   👤 #{regular_users.size} regular users created"
puts "   🎯 #{groups_data.size} targeting groups created"
puts "   🚩 #{created_flags.size} feature flags created"
puts "   📋 #{rules_created} targeting rules created"
puts
puts "🔐 Login credentials:"
puts "   Admin: admin / password"
puts "   User examples: alice / alice123, bob / bob123"
