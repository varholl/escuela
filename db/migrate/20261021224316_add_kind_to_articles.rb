# Reflections for anyone, notes for colleagues. Everything written before this
# was a reflection, which is what the default gives it.
class AddKindToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :kind, :integer, default: 0, null: false

    add_index :articles, [ :kind, :locale, :published_at ]
  end
end
