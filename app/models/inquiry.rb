# A message left through the contact form. Kept in the database rather than only
# emailed so nothing is lost to a spam folder.
class Inquiry < ApplicationRecord
  include Localizable

  belongs_to :course, optional: true

  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 4000 }
  validates :phone, length: { maximum: 40 }

  scope :unhandled, -> { where(handled_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }

  def handled?
    handled_at.present?
  end
end
