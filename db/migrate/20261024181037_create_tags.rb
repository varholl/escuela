# Internal labels on what she writes and teaches -- never shown on the site --
# so a course can be matched with the people who read about its subject.
class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :taggings, [ :taggable_type, :taggable_id, :tag_id ], unique: true
  end
end
