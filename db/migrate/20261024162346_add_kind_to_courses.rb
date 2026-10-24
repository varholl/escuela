# A course is a series of lessons; a workshop is one recorded talk or
# workshop, sold and gated the same way. Everything built before this was a
# course, which is what the default gives it.
class AddKindToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :kind, :integer, default: 0, null: false

    add_index :courses, [ :kind, :locale, :status ]
  end
end
