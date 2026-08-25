class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.string     :name, null: false
      t.string     :email, null: false
      t.string     :phone
      t.references :course, foreign_key: true
      t.text       :message, null: false
      t.string     :locale, null: false, default: "es"
      t.datetime   :handled_at

      t.timestamps
    end

    add_index :inquiries, :created_at
  end
end
