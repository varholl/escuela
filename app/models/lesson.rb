# A single video unit inside a course. `video_provider` says where the file
# actually lives and `video_reference` holds the identifier that provider uses;
# together they let one lesson play from our own bucket and the next from
# YouTube, without the views having to care which.
class Lesson < ApplicationRecord
  include Sluggable
  include Publishable
  include OrganisedAttachments

  # Our own bucket is the only private option -- an unlisted YouTube or Vimeo
  # link is reachable by anyone who has it. Kept in the order she chooses from.
  VIDEO_PROVIDERS = %w[ active_storage youtube vimeo ].freeze

  belongs_to :course, inverse_of: :lessons

  slugged_from :title, scope: :course_id

  has_rich_text :notes
  has_one_attached :video

  validates :title, presence: true, length: { maximum: 160 }
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_seconds, numericality: { greater_than: 0 }, allow_nil: true
  validates :video_provider, inclusion: { in: VIDEO_PROVIDERS }, allow_blank: true

  scope :ordered, -> { order(:position, :id) }

  # Active Storage records the duration while analysing the upload, but only
  # where ffprobe exists. A value typed by hand always wins: she may want to
  # advertise the practice time rather than the file's length.
  def absorb_video_duration
    return unless duration_seconds.blank? && video.attached?

    seconds = video.blob.metadata[:duration]
    return if seconds.blank?

    update_column(:duration_seconds, seconds.round)
  end

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
