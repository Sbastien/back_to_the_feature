class FlagEvaluationService
  def initialize(flag, context = {})
    @flag = flag
    @context = context
    @user_attributes = context[:user_attributes] || {}
    @user_id = context[:user_id] || @user_attributes['id']
  end

  def evaluate
    # Check for kill switch first (boolean off rule)
    kill_switch_rule = @flag.rules.find { |rule| rule.kill_switch? }
    if kill_switch_rule
      return {
        enabled: false,
        variant: nil,
        rule_type: "boolean",
        rule_id: kill_switch_rule.id
      }
    end

    # Check rules in order of creation
    @flag.rules.ordered.each do |rule|
      next if rule.kill_switch? # Already handled above

      if rule.applies_to?(@context.merge(user_attributes: @user_attributes))
        variant = determine_variant(rule)
        return {
          enabled: true,
          variant: variant,
          rule_type: rule.type,
          rule_id: rule.id
        }
      end
    end

    # No rules matched
    {
      enabled: false,
      variant: nil,
      rule_type: nil,
      rule_id: nil
    }
  end

  private

  def determine_variant(rule)
    case rule.type
    when "percentage_of_actors"
      # Use the same hash as the rule to determine variant within the percentage
      return @flag.variants.first["name"] unless @user_id

      hash = Digest::SHA256.hexdigest("#{@flag.name}:variant:#{@user_id}")
      percentage = hash.to_i(16) % 100
      @flag.variant_for_percentage(percentage)
    else
      # For boolean and group rules, use user_id to determine variant
      if @user_id
        hash = Digest::SHA256.hexdigest("#{@flag.name}:variant:#{@user_id}")
        percentage = hash.to_i(16) % 100
        @flag.variant_for_percentage(percentage)
      else
        @flag.variants.first["name"]
      end
    end
  end
end