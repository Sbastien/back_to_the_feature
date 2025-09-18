class FlagEvaluationService
  def initialize(flag, context = {})
    @flag = flag
    @context = context
    @user_attributes = context[:user_attributes] || {}
    @user_id = context[:user_id] || @user_attributes["id"]
  end

  def evaluate
    # Check if flag is globally disabled (kill switch)
    unless @flag.enabled?
      return {
        enabled: false,
        rule_type: "kill_switch",
        rule_id: nil
      }
    end

    # Check rules in order of creation
    @flag.rules.ordered.each do |rule|
      if rule.applies_to?(@context.merge(user_attributes: @user_attributes))
        return {
          enabled: true,
          rule_type: rule.type,
          rule_id: rule.id
        }
      end
    end

    # No rules matched
    {
      enabled: false,
      rule_type: nil,
      rule_id: nil
    }
  end
end
