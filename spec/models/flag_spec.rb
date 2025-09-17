require 'rails_helper'

RSpec.describe Flag, type: :model do
  describe "validations" do
    it "validates presence of name" do
      flag = Flag.new(description: "test")
      expect(flag).not_to be_valid
      expect(flag.errors[:name]).to include("can't be blank")
    end

    it "validates uniqueness of name" do
      Flag.create!(name: "test", description: "test")
      flag = Flag.new(name: "test", description: "test")
      expect(flag).not_to be_valid
      expect(flag.errors[:name]).to include("has already been taken")
    end

    it "validates presence of variants" do
      flag = Flag.new(name: "test", description: "test", variants: [])
      expect(flag).not_to be_valid
      expect(flag.errors[:variants]).to include("can't be blank")
    end
  end

  describe "defaults" do
    it "sets default variants on creation" do
      flag = Flag.create!(name: "test", description: "test")
      expect(flag.variants).to eq([
        { "name" => "A", "weight" => 50 },
        { "name" => "B", "weight" => 50 }
      ])
    end
  end

  describe "#total_weight" do
    it "calculates total weight of all variants" do
      flag = Flag.new(variants: [
        { "name" => "A", "weight" => 30 },
        { "name" => "B", "weight" => 70 }
      ])
      expect(flag.total_weight).to eq(100)
    end
  end

  describe "#variant_for_percentage" do
    let(:flag) do
      Flag.new(variants: [
        { "name" => "A", "weight" => 30 },
        { "name" => "B", "weight" => 70 }
      ])
    end

    it "returns first variant for low percentages" do
      expect(flag.variant_for_percentage(10)).to eq("A")
    end

    it "returns second variant for high percentages" do
      expect(flag.variant_for_percentage(50)).to eq("B")
    end

    it "returns nil for percentages outside range" do
      expect(flag.variant_for_percentage(-1)).to be_nil
      expect(flag.variant_for_percentage(101)).to be_nil
    end
  end
end