# Lessons carry the video content sold in phase two. The video itself is kept
# provider-agnostic: `video_provider` names the backend ("active_storage",
# "vimeo", "mux", ...) and `video_reference` holds whatever identifier that
# backend needs, so switching hosts never requires a schema change.
class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.string     :title, null: false
      t.string     :slug, null: false
      t.text       :summary
      t.integer    :position, null: false, default: 0
      t.integer    :duration_seconds
      t.string     :video_provider
      t.string     :video_reference
      t.boolean    :free_preview, null: false, default: false
      t.datetime   :published_at

      t.timestamps
    end

    add_index :lessons, [ :course_id, :position ]
    add_index :lessons, [ :course_id, :slug ], unique: true
  end
end
