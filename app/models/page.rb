# Editable copy for the standing pages, so the owner can rewrite her own bio
# from the admin panel instead of waiting on a deploy.
class Page < ApplicationRecord
  include Localizable
  include OrganisedAttachments

  KEYS = %w[ home about philosophy privacy terms ].freeze

  has_rich_text :body
  has_one_attached :cover_image

  # The institutional video on the home page. Lives here so she can replace it
  # from the panel instead of asking for a deploy.
  has_one_attached :feature_video

  validates :key, presence: true, inclusion: { in: KEYS }, uniqueness: { scope: :locale }
  validates :title, length: { maximum: 160 }
  validates :subtitle, length: { maximum: 240 }

  def feature_video?
    feature_video.attached?
  end

  def storage_folder
    "paginas/#{key}-#{locale}"
  end

  # Falls back to the default locale so an untranslated page still renders.
  def self.for(key, locale: I18n.locale)
    in_locale(locale).find_by(key: key.to_s) ||
      in_locale(I18n.default_locale).find_by(key: key.to_s)
  end
end
