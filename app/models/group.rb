class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :definition, presence: true
  validate :validate_expression_syntax

  # Association-style method that returns a relation for counting/checking
  def rules
    Rule.where(type: "group", value: name)
  end

  # Memoized rule count for performance
  def rule_count
    @rule_count ||= rules.count
  end

  # Check if any rules exist
  def has_rules?
    rules.exists?
  end

  # Evaluate group membership based on user attributes sent by client application
  def includes_user?(user_attributes)
    return false unless user_attributes.is_a?(Hash)

    # Ensure all attributes are strings for consistent JMESPath evaluation
    normalized_attributes = normalize_attributes(user_attributes)

    # Use JMESPath for safe expression evaluation
    result = JMESPath.search(definition, normalized_attributes)

    # JMESPath returns various types, convert to boolean
    case result
    when true, false
      result
    when nil
      false
    when String
      !result.empty?
    when Numeric
      result != 0
    when Array
      !result.empty?
    else
      !!result
    end
  rescue JMESPath::Errors::Error => e
    Rails.logger.error "JMESPath evaluation error for group #{name}: #{e.message}"
    false
  rescue StandardError => e
    Rails.logger.error "Unexpected error evaluating group #{name}: #{e.message}"
    false
  end

  # Helper method to get example expressions for the UI
  def self.example_expressions
    {
      "Premium users" => "role == 'premium'",
      "Company emails" => "ends_with(email, '@company.com')",
      "Beta testers" => "ends_with(email, '@example.com')",
      "US/CA users" => "contains(['US', 'CA'], country)",
      "Active users" => "status == 'active'",
      "Specific IDs" => "contains([1, 2, 3, 4, 5], id)",
      "Pro subscribers" => "subscription == 'pro'",
      "Admin users" => "starts_with(username, 'admin_')",
      "Has email" => "email",
      "Not premium" => "role != 'premium'"
    }
  end

  private

  def validate_expression_syntax
    return if definition.blank?

    unless GroupExpressionValidator.valid?(definition)
      validator = GroupExpressionValidator.new(definition)
      errors.add(:definition, "Invalid expression: #{validator.errors.join(', ')}")
    end
  end

  def normalize_attributes(user_attributes)
    normalized = {}

    user_attributes.each do |key, value|
      # Convert all keys to strings
      string_key = key.to_s

      # Convert values to appropriate types for JMESPath
      normalized[string_key] = case value
      when String, Integer, Float, TrueClass, FalseClass, NilClass
                                 value
      else
                                 value.to_s
      end
    end

    normalized
  end
end
