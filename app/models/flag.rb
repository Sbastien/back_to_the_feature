class Flag < ApplicationRecord
  has_many :rules, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :variants, presence: true

  before_validation :set_default_variants, on: :create

  def total_weight
    variants.sum { |variant| variant["weight"] }
  end

  def variant_for_percentage(percentage)
    return nil unless percentage.between?(0, 100)

    cumulative_weight = 0
    normalized_percentage = (percentage * total_weight / 100.0).to_i

    variants.each do |variant|
      cumulative_weight += variant["weight"]
      return variant["name"] if normalized_percentage < cumulative_weight
    end

    variants.last["name"]
  end

  private

  def set_default_variants
    self.variants ||= [
      { "name" => "A", "weight" => 50 },
      { "name" => "B", "weight" => 50 }
    ]
  end
end