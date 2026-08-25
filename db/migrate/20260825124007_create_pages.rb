# Editable long-form copy for the standing pages (about, philosophy) so the
# owner can rewrite her own bio without a deploy.
class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string :key, null: false
      t.string :locale, null: false, default: "es"
      t.string :title
      t.string :subtitle

      t.timestamps
    end

    add_index :pages, [ :key, :locale ], unique: true
  end
end
