# Courses are private: a lesson is only ever visible to someone enrolled in its
# course. The open-session flag granted public access, which contradicts that,
# and a checkbox that no longer opens anything is worse than no checkbox.
class RemoveFreePreviewFromLessons < ActiveRecord::Migration[8.1]
  def change
    remove_column :lessons, :free_preview, :boolean, null: false, default: false
  end
end
