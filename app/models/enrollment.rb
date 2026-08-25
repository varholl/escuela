# The single answer to "may this student watch this course". Phase one grants
# these by hand from the admin panel; when payments land, the provider's webhook
# becomes just another writer of the same record -- `source` says which.
class Enrollment < ApplicationRecord
  SOURCES = %w[ manual self_serve payment gift ].freeze

  belongs_to :user
  belongs_to :course

  enum :status, { pending: 0, active: 1, completed: 2, cancelled: 3 },
    default: :pending, validate: true

  validates :source, inclusion: { in: SOURCES }
  validates :user_id, uniqueness: { scope: :course_id }

  scope :granting_access, -> { active.where(expires_at: nil).or(active.where(expires_at: Time.current..)) }

  def grants_access?
    active? && (expires_at.nil? || expires_at.future?)
  end
end
