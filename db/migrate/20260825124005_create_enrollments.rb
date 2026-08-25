# An enrollment is the single source of truth for "may this student watch this
# course". Phase one grants them by hand from the admin panel; phase two will
# have the payment provider's webhook create them, which is why `source`
# records where the grant came from.
class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer    :status, null: false, default: 0
      t.string     :source, null: false, default: "manual"
      t.datetime   :granted_at
      t.datetime   :expires_at

      t.timestamps
    end

    add_index :enrollments, [ :user_id, :course_id ], unique: true
  end
end
