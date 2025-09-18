require 'rails_helper'

RSpec.describe FlagEvaluationService do
  let(:flag) { create(:flag) }
  let(:user) { create(:user) }

  describe "#evaluate" do
    context "with disabled flag" do
      before do
        flag.update!(enabled: false)
      end

      it "returns disabled when flag is globally disabled" do
        service = FlagEvaluationService.new(flag, user_id: user.id)
        result = service.evaluate

        expect(result[:enabled]).to be false
        expect(result[:rule_type]).to eq("kill_switch")
      end
    end


    context "with percentage rule" do
      before do
        create(:rule, flag: flag, type: "percentage_of_actors", value: "50")
      end

      it "returns consistent results for the same user" do
        service = FlagEvaluationService.new(flag, user_id: user.id)
        result1 = service.evaluate
        result2 = service.evaluate

        expect(result1[:enabled]).to eq(result2[:enabled])
      end
    end

    context "with no matching rules" do
      it "returns disabled" do
        service = FlagEvaluationService.new(flag, user_id: user.id)
        result = service.evaluate

        expect(result[:enabled]).to be false
        expect(result[:rule_type]).to be_nil
      end
    end
  end
end
