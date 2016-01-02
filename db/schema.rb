# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160102130750) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "name"
    t.string   "steam_name"
    t.integer  "steam_id"
    t.integer  "steam_price"
    t.integer  "steam_sale_price"
    t.integer  "steam_reviews_ratio"
    t.integer  "steam_reviews_count"
    t.string   "steam_thumbnail"
    t.datetime "released_at"
    t.datetime "steam_list_scraped_at"
    t.integer  "platforms",                    default: 0,  null: false
    t.string   "name_slug"
    t.string   "tags"
    t.string   "genre"
    t.integer  "dlc_count"
    t.integer  "steam_achievements_count"
    t.string   "audio_languages"
    t.string   "subtitles_languages"
    t.integer  "metacritic"
    t.string   "esrb_rating"
    t.text     "videos"
    t.text     "images"
    t.text     "summary"
    t.boolean  "early_access"
    t.text     "system_requirements"
    t.integer  "players"
    t.integer  "controller_support"
    t.integer  "features"
    t.integer  "positive_steam_reviews_count"
    t.integer  "negative_steam_reviews_count"
    t.datetime "steam_game_scraped_at"
    t.text     "positive_steam_reviews"
    t.text     "negative_steam_reviews"
    t.datetime "steam_reviews_scraped_at"
    t.integer  "lowest_steam_price"
    t.integer  "steam_discount"
    t.float    "playtime_mean"
    t.float    "playtime_median"
    t.float    "playtime_sd"
    t.float    "playtime_rsd"
    t.string   "playtime_ils"
    t.float    "playtime_mean_ftb"
    t.float    "playtime_median_ftb"
    t.integer  "vr",                           default: 0,  null: false
    t.string   "sysreq_video_tokens",          default: "", null: false
    t.integer  "sysreq_video_index"
  end

  create_table "gpus", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name"
    t.integer  "value"
    t.string   "tokenized_name"
  end

  create_table "named_filters", force: :cascade do |t|
    t.string   "name"
    t.string   "columns"
    t.text     "filters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sysreq_tokens", force: :cascade do |t|
    t.string   "name",                          null: false
    t.integer  "value"
    t.integer  "token_type",    default: 0,     null: false
    t.integer  "games_count",   default: 0,     null: false
    t.boolean  "year_analysis", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
