class Flag < ApplicationRecord
  has_many :rules, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
