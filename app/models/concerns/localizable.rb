# Content is authored once per language rather than translated field by field:
# a Spanish note and its English counterpart are two records that differ in
# `locale`. Public pages only ever list the records matching the current locale.
module Localizable
  extend ActiveSupport::Concern

  included do
    validates :locale, presence: true,
      inclusion: { in: ->(_record) { I18n.available_locales.map(&:to_s) } }

    scope :in_locale, ->(locale) { where(locale: locale.to_s) }
  end
end
