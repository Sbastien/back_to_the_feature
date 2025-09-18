class GroupExpressionValidator
  # Allowed JMESPath functions for security
  ALLOWED_FUNCTIONS = %w[
    contains ends_with starts_with length
    type not_null to_string to_number
  ].freeze

  def self.valid?(expression)
    new(expression).valid?
  end

  def self.validate!(expression)
    validator = new(expression)
    unless validator.valid?
      raise ArgumentError, "Invalid expression: #{validator.errors.join(', ')}"
    end
    true
  end

  def initialize(expression)
    @expression = expression.to_s.strip
    @errors = []
  end

  def valid?
    return false if @expression.nil? || @expression.strip.empty?

    validate_syntax
    validate_security

    @errors.empty?
  end

  def errors
    @errors
  end

  private

  def validate_syntax
    # Test if JMESPath can parse the expression with sample data
    sample_data = {
      "id" => 1,
      "email" => "test@example.com",
      "username" => "testuser",
      "role" => "user",
      "country" => "US",
      "subscription" => "basic"
    }

    JMESPath.search(@expression, sample_data)
  rescue JMESPath::Errors::Error => e
    @errors << "Invalid syntax: #{e.message}"
  end

  def validate_security
    # Check for dangerous patterns that could be security risks
    dangerous_patterns = [
      /system/i, /exec/i, /eval/i, /`/, /\$/, /#\{/,
      /class/i, /method/i, /send/i, /const_get/i,
      /require/i, /load/i, /instance_variable/i
    ]

    dangerous_patterns.each do |pattern|
      if @expression.match?(pattern)
        @errors << "Expression contains forbidden pattern: #{pattern.source}"
      end
    end

    # Ensure expression length is reasonable
    if @expression.length > 500
      @errors << "Expression is too long (max 500 characters)"
    end
  end
end
