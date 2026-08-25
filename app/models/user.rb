class User < ApplicationRecord
  # Only ever used to confirm a change of email or password on the account
  # screen; never persisted.
  attr_accessor :current_password

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments

  enum :role, { student: 0, admin: 1 }, default: :student, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, length: { maximum: 120 }

  def display_name
    name.presence || email_address.split("@").first
  end
end
