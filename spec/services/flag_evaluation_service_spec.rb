require 'rails_helper'

RSpec.describe FlagEvaluationService do
  let(:flag) { create(:flag) }
  let(:user) { create(:user) }

  describe "#evaluate" do
    context "with kill switch rule" do
      before do
        create(:rule, flag: flag, type: "boolean", value: "off")
        create(:rule, flag: flag, type: "percentage_of_actors", value: "100")
      end

      it "returns disabled when kill switch is active" do
        service = FlagEvaluationService.new(flag, user_id: user.id, user: user)
        result = service.evaluate

        expect(result[:enabled]).to be false
        expect(result[:variant]).to be_nil
        expect(result[:rule_type]).to eq("boolean")
      end
    end

    context "with group rule" do
      let(:group) { create(:group, name: "test_group", definition: 'username.starts_with? "test"') }

      before do
        create(:rule, flag: flag, type: "group", value: group.name)
      end

      it "returns enabled for users in the group" do
        user = create(:user, username: "test_user")
        service = FlagEvaluationService.new(flag, user_id: user.id, user: user)
        result = service.evaluate

        expect(result[:enabled]).to be true
        expect(result[:rule_type]).to eq("group")
        expect(result[:variant]).to be_present
      end

      it "returns disabled for users not in the group" do
        user = create(:user, username: "other_user")
        service = FlagEvaluationService.new(flag, user_id: user.id, user: user)
        result = service.evaluate

        expect(result[:enabled]).to be false
        expect(result[:variant]).to be_nil
      end
    end

    context "with percentage rule" do
      before do
        create(:rule, flag: flag, type: "percentage_of_actors", value: "50")
      end

      it "returns consistent results for the same user" do
        service = FlagEvaluationService.new(flag, user_id: user.id, user: user)
        result1 = service.evaluate
        result2 = service.evaluate

        expect(result1[:enabled]).to eq(result2[:enabled])
        expect(result1[:variant]).to eq(result2[:variant])
      end
    end

    context "with no matching rules" do
      it "returns disabled" do
        service = FlagEvaluationService.new(flag, user_id: user.id, user: user)
        result = service.evaluate

        expect(result[:enabled]).to be false
        expect(result[:variant]).to be_nil
        expect(result[:rule_type]).to be_nil
      end
    end
  end
end