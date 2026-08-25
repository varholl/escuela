class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string   :title, null: false
      t.string   :slug, null: false
      t.string   :subtitle
      t.text     :summary
      t.string   :locale, null: false, default: "es"
      t.integer  :status, null: false, default: 0
      t.integer  :modality, null: false, default: 0
      t.integer  :price_cents
      t.string   :currency, null: false, default: "ARS"
      t.string   :duration_label
      t.date     :starts_on
      t.integer  :position, null: false, default: 0
      t.datetime :published_at

      t.timestamps
    end

    add_index :courses, :slug, unique: true
    add_index :courses, [ :locale, :status, :position ]
  end
end
