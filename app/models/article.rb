class Article < ApplicationRecord
  include Sluggable
  include Localizable
  include OrganisedAttachments
  include Publishable

  WORDS_PER_MINUTE = 200

  # Two sections of the same kind of writing. Reflections are for anyone; notes
  # ("apuntes") are working material for other professionals. Each has its own
  # address on the site -- /reflexiones and /apuntes -- but they share
  # everything else.
  enum :kind, { reflection: 0, note: 1 }, default: :reflection, validate: true

  slugged_from :title

  has_rich_text :body
  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 160 }
  validates :excerpt, length: { maximum: 400 }

  # "notas" is what the section was called when the first covers were filed.
  # Changing it would mean moving every one of them, for no visible gain.
  def storage_folder
    slug.presence && "notas/#{slug}"
  end

  def reading_time_minutes
    [ (body.to_plain_text.split.size / WORDS_PER_MINUTE.to_f).ceil, 1 ].max
  end

  def summary
    excerpt.presence || body.to_plain_text.truncate(200)
  end
end
