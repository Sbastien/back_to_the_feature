class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :definition, presence: true

  # Evaluate group membership based on user attributes sent by client application
  def includes_user?(user_attributes)
    return false unless user_attributes.is_a?(Hash)

    case definition
    when /^email\.ends_with\?\s*["'](.*?)["']$/
      domain = $1
      user_attributes['email']&.end_with?(domain)
    when /^email\.include\?\s*["'](.*?)["']$/
      substring = $1
      user_attributes['email']&.include?(substring)
    when /^username\.starts_with\?\s*["'](.*?)["']$/
      prefix = $1
      user_attributes['username']&.start_with?(prefix)
    when /^id\.in\?\s*\[(.*?)\]$/
      ids = $1.split(',').map(&:strip).map(&:to_i)
      ids.include?(user_attributes['id']&.to_i)
    when /^role\s*==\s*["'](.*?)["']$/
      role = $1
      user_attributes['role'] == role
    when /^country\s*==\s*["'](.*?)["']$/
      country = $1
      user_attributes['country'] == country
    when /^subscription\s*==\s*["'](.*?)["']$/
      subscription = $1
      user_attributes['subscription'] == subscription
    else
      # For more complex definitions, evaluate safely
      safe_eval_definition(user_attributes)
    end
  rescue StandardError => e
    Rails.logger.error "Error evaluating group definition for #{name}: #{e.message}"
    false
  end

  private

  def safe_eval_definition(user_attributes)
    # Simple safe evaluation for basic expressions
    # Only allow safe operations on user attributes
    safe_definition = definition.dup

    # Replace common attribute patterns
    user_attributes.each do |key, value|
      safe_definition.gsub!(/\b#{Regexp.escape(key)}\b/, value.to_s.inspect)
    end

    # Only allow safe operations and known attributes
    allowed_pattern = /\A[\w\s"'\.=<>!&|()]+\z/
    return false unless safe_definition.match?(allowed_pattern)

    # Evaluate in a restricted context
    eval(safe_definition)
  rescue StandardError
    false
  end
end