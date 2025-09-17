class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[admin user] }

  enum :role, { user: "user", admin: "admin" }

  def admin?
    role == "admin"
  end
end