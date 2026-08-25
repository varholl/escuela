# Draft-until-dated publishing: a record is public once `published_at` is set
# and has passed, which also allows scheduling something for a future date.
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where.not(published_at: nil).where(published_at: ..Time.current) }
    scope :drafted, -> { where(published_at: nil) }
    scope :scheduled, -> { where(published_at: Time.current..) }
    scope :recent_first, -> { order(published_at: :desc, created_at: :desc) }
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end

  def drafted?
    published_at.nil?
  end
end
