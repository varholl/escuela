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

  # Enrollment is the gate even when the course costs nothing: she wants to know
  # who her students are, and phase two hangs the paid flow on the same record.
  def enrolled?(user)
    user.present? && enrollments.granting_access.exists?(user: user)
  end

  # Only free courses can be joined without her: a paid one still goes through
  # the contact form until there is a way to take money.
  def joinable_by?(user)
    user.present? && published? && free? && !enrolled?(user)
  end

  def join!(user, source: "self_serve")
    enrollments.create!(user: user, status: :active, source: source, granted_at: Time.current)
  end

  def lessons_visible_to(user)
    return lessons.ordered if user&.admin?

    lessons.published.ordered
  end
end
