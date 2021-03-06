# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_04_061130) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "collected_inks", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "private", default: false
    t.string "brand_name", limit: 100, null: false
    t.string "line_name", limit: 100, default: "", null: false
    t.string "ink_name", limit: 100, null: false
    t.text "comment", default: ""
    t.string "simplified_brand_name", limit: 100
    t.string "simplified_line_name", limit: 100
    t.string "simplified_ink_name", limit: 100
    t.string "color", limit: 7, default: "", null: false
    t.boolean "swabbed", default: false, null: false
    t.boolean "used", default: false, null: false
    t.date "archived_on"
    t.bigint "ink_brand_id"
    t.text "maker", default: ""
    t.integer "new_ink_name_id"
    t.integer "currently_inked_count", default: 0
    t.index ["brand_name"], name: "index_collected_inks_on_brand_name"
    t.index ["ink_brand_id"], name: "index_collected_inks_on_ink_brand_id"
    t.index ["ink_name"], name: "index_collected_inks_on_ink_name"
    t.index ["line_name"], name: "index_collected_inks_on_line_name"
    t.index ["simplified_ink_name"], name: "index_collected_inks_on_simplified_ink_name"
  end

  create_table "collected_pens", force: :cascade do |t|
    t.string "brand", limit: 100, null: false
    t.string "model", limit: 100, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.string "nib", limit: 100
    t.string "color", limit: 100
    t.date "archived_on"
  end

  create_table "currently_inked", force: :cascade do |t|
    t.text "comment"
    t.bigint "collected_ink_id", null: false
    t.bigint "collected_pen_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.date "archived_on"
    t.date "inked_on", null: false
    t.string "nib", limit: 100, default: ""
    t.index ["collected_ink_id"], name: "index_currently_inked_on_collected_ink_id"
    t.index ["collected_pen_id"], name: "index_currently_inked_on_collected_pen_id"
    t.index ["user_id"], name: "index_currently_inked_on_user_id"
  end

  create_table "ink_brands", force: :cascade do |t|
    t.text "simplified_name"
    t.text "popular_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "new_ink_names_count", default: 0
    t.index ["simplified_name"], name: "index_ink_brands_on_simplified_name", unique: true
  end

  create_table "new_ink_names", force: :cascade do |t|
    t.text "simplified_name", null: false
    t.text "popular_name"
    t.integer "ink_brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "collected_inks_count", default: 0
    t.text "popular_line_name", default: ""
    t.string "color", limit: 7, default: "", null: false
    t.index ["popular_line_name"], name: "index_new_ink_names_on_popular_line_name"
    t.index ["popular_name"], name: "index_new_ink_names_on_popular_name"
    t.index ["simplified_name", "ink_brand_id"], name: "index_new_ink_names_on_simplified_name_and_ink_brand_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 100
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.text "blurb", default: ""
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "collected_inks", "ink_brands"
  add_foreign_key "collected_inks", "new_ink_names"
  add_foreign_key "collected_inks", "users"
  add_foreign_key "collected_pens", "users"
  add_foreign_key "currently_inked", "collected_inks"
  add_foreign_key "currently_inked", "collected_pens"
  add_foreign_key "currently_inked", "users"
  add_foreign_key "new_ink_names", "ink_brands"
end
