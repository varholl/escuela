# An internal label -- "ansiedad", "insomnio", "duelo" -- on pieces and courses.
# Never shown on the site; it is how a course finds the people who have been
# reading about its subject.
class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  # One spelling per idea, so "Ansiedad " and "ansiedad" are the same tag.
  normalizes :name, with: ->(name) { name.to_s.squish.downcase }

  validates :name, presence: true, uniqueness: true, length: { maximum: 40 }

  scope :alphabetical, -> { order(:name) }
end
