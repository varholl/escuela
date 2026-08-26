# A single video unit inside a course. Phase one only stores the metadata; the
# gated player arrives with the paid tier. `video_provider` / `video_reference`
# keep us free to host on Active Storage now and move to Mux or Vimeo later.
class Lesson < ApplicationRecord
  include Sluggable
  include Publishable
  include OrganisedAttachments

  VIDEO_PROVIDERS = %w[ active_storage vimeo mux youtube ].freeze

  belongs_to :course, inverse_of: :lessons

  slugged_from :title, scope: :course_id

  has_rich_text :notes
  has_one_attached :video

  validates :title, presence: true, length: { maximum: 160 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_seconds, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_provider, inclusion: { in: VIDEO_PROVIDERS }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }

  def storage_folder
    return nil if slug.blank? || course&.slug.blank?

    "cursos/#{course.slug}/#{slug}"
  end

  # Courses are private. Nothing here is readable without a place in the course,
  # signed in or not. Admins get through so she can proof her own material.
  def viewable_by?(user)
    return true if user&.admin?
    return false unless published?

    course.enrolled?(user)
  end

  def duration
    return nil if duration_seconds.blank?

    Time.at(duration_seconds).utc.strftime(duration_seconds >= 3600 ? "%-H:%M:%S" : "%-M:%S")
  end
end
