# Internal tags on a record, edited as one comma-separated field.
#
# The list is applied after the record saves, so a form that fails validation
# leaves no stray tags behind, and a new record has an id to tag.
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, -> { alphabetical }, through: :taggings

    after_save :apply_tag_list, if: -> { @tag_list }
  end

  def tag_list
    @tag_list || tags.map(&:name).join(", ")
  end

  def tag_list=(value)
    @tag_list = value.to_s
  end

  private
    def apply_tag_list
      names = @tag_list.split(",").map { |name| name.squish.downcase }.compact_blank.uniq
      self.tags = names.map { |name| Tag.find_or_create_by!(name: name) }
      @tag_list = nil
    end
end
