# Gives a model a URL-friendly `slug` derived from another attribute, so records
# are addressed as /notas/coherencia-cuerpo-mente rather than /notas/42.
#
# The slug is only derived when blank, which means it survives later edits to
# the title -- published URLs keep working -- while still letting the admin set
# one by hand.
module Sluggable
  extend ActiveSupport::Concern

  FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

  included do
    class_attribute :slug_source, instance_writer: false, default: :title
    class_attribute :slug_uniqueness_scope, instance_writer: false, default: nil

    before_validation :derive_slug

    validates :slug, presence: true, format: { with: FORMAT }
  end

  class_methods do
    def slugged_from(attribute, scope: nil)
      self.slug_source = attribute
      self.slug_uniqueness_scope = scope

      validates :slug, uniqueness: { scope: scope, case_sensitive: false }
    end
  end

  def to_param
    slug
  end

  private
    def derive_slug
      return if slug.present?

      base = public_send(slug_source).to_s.parameterize
      self.slug = base.present? ? unique_slug(base) : nil
    end

    def unique_slug(base)
      candidate = base
      suffix = 1

      while slug_taken?(candidate)
        suffix += 1
        candidate = "#{base}-#{suffix}"
      end

      candidate
    end

    def slug_taken?(candidate)
      scope = self.class.where(slug: candidate)
      scope = scope.where(slug_uniqueness_scope => public_send(slug_uniqueness_scope)) if slug_uniqueness_scope
      scope = scope.where.not(id: id) if persisted?
      scope.exists?
    end
end
