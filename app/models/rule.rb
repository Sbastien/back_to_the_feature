class Rule < ApplicationRecord
  # Disable single table inheritance for this model
  self.inheritance_column = nil

  belongs_to :flag

  validates :type, inclusion: { in: %w[percentage_of_actors group] }
  validates :value, presence: true
  validate :validate_value_for_type

  scope :ordered, -> { order(:created_at) }

  def applies_to?(context)
    case type
    when "percentage_of_actors"
      user_id = context[:user_id] || context[:user_attributes]&.dig("id")
      return false unless user_id
      user_percentage(user_id) < value.to_i
    when "group"
      user_attributes = context[:user_attributes]
      return false unless user_attributes
      group = Group.find_by(name: value)
      return false unless group
      group.includes_user?(user_attributes)
    else
      false
    end
  end


  private

  def validate_value_for_type
    case type
    when "percentage_of_actors"
      percentage = value.to_i
      errors.add(:value, "must be between 0 and 100") unless percentage.between?(0, 100)
    when "group"
      errors.add(:value, "group does not exist") unless Group.exists?(name: value)
    end
  end

  def user_percentage(user_id)
    hash = Digest::SHA256.hexdigest("#{flag.name}:#{user_id}")
    hash.to_i(16) % 100
  end
end
