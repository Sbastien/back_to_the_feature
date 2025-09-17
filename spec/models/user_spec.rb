require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "validates presence of username" do
      user = User.new(password: "password")
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it "validates uniqueness of username" do
      User.create!(username: "test", password: "password")
      user = User.new(username: "test", password: "password")
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("has already been taken")
    end

    it "validates inclusion of role" do
      expect {
        User.new(username: "test", password: "password", role: "invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid role")
    end
  end

  describe "defaults" do
    it "defaults role to user" do
      user = User.create!(username: "test", password: "password")
      expect(user.role).to eq("user")
    end
  end

  describe "#admin?" do
    it "returns true for admin users" do
      user = User.new(role: "admin")
      expect(user).to be_admin
    end

    it "returns false for regular users" do
      user = User.new(role: "user")
      expect(user).not_to be_admin
    end
  end
end