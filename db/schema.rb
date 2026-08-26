# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_26_200001) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.string "locale", default: "es", null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["locale", "published_at"], name: "index_articles_on_locale_and_published_at"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency", default: "ARS", null: false
    t.string "duration_label"
    t.string "locale", default: "es", null: false
    t.integer "modality", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.integer "price_cents"
    t.datetime "published_at"
    t.string "slug", null: false
    t.date "starts_on"
    t.integer "status", default: 0, null: false
    t.string "subtitle"
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["locale", "status", "position"], name: "index_courses_on_locale_and_status_and_position"
    t.index ["slug"], name: "index_courses_on_slug", unique: true
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "granted_at"
    t.string "source", default: "manual", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.integer "course_id"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "handled_at"
    t.string "locale", default: "es", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_inquiries_on_course_id"
    t.index ["created_at"], name: "index_inquiries_on_created_at"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.integer "position", default: 0, null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "video_provider"
    t.string "video_reference"
    t.index ["course_id", "position"], name: "index_lessons_on_course_id_and_position"
    t.index ["course_id", "slug"], name: "index_lessons_on_course_id_and_slug", unique: true
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "locale", default: "es", null: false
    t.string "subtitle"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["key", "locale"], name: "index_pages_on_key_and_locale", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.string "provider"
    t.integer "role", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "inquiries", "courses"
  add_foreign_key "lessons", "courses"
  add_foreign_key "sessions", "users"
end
