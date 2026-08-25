class Course < ApplicationRecord
  include Sluggable
  include Localizable

  slugged_from :title

  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft, validate: true
  enum :modality, { online_live: 0, on_demand: 1, in_person: 2, hybrid: 3 },
    default: :online_live, validate: true

  has_rich_text :description
  has_one_attached :cover_image

  has_many :lessons, -> { order(:position) }, dependent: :destroy, inverse_of: :course
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :inquiries, dependent: :nullify

  validates :title, presence: true, length: { maximum: 160 }
  validates :subtitle, length: { maximum: 240 }
  validates :summary, length: { maximum: 600 }
  validates :currency, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :ordered, -> { order(:position, :starts_on, :title) }

  def free?
    price_cents.nil? || price_cents.zero?
  end

  def price
    price_cents && price_cents / 100.0
  end

  def upcoming?
    starts_on.present? && starts_on >= Date.current
  end
end
