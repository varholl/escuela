class Article < ApplicationRecord
  include Sluggable
  include Localizable
  include OrganisedAttachments
  include Publishable

  WORDS_PER_MINUTE = 200

  slugged_from :title

  has_rich_text :body
  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 160 }
  validates :excerpt, length: { maximum: 400 }

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
