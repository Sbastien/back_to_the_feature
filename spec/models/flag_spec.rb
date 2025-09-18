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
  end

  describe "associations" do
    it "has many rules" do
      flag = Flag.create!(name: "test", description: "test")
      expect(flag.rules).to be_empty
    end
  end
end
