class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string   :title, null: false
      t.string   :slug, null: false
      t.text     :excerpt
      t.string   :locale, null: false, default: "es"
      t.datetime :published_at

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, [ :locale, :published_at ]
  end
end
