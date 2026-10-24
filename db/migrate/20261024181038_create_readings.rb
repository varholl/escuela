# Which pieces someone opened, and when last -- only for those who said yes to
# it. Nothing else: not how long they stayed, not where they went next.
class CreateReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :readings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true
      t.datetime :last_read_at, null: false
      t.timestamps
    end
    add_index :readings, [ :user_id, :article_id ], unique: true
  end
end
