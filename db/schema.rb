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

ActiveRecord::Schema.define(version: 20161112005954) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "filters", force: :cascade do |t|
    t.string   "sid",                          null: false
    t.string   "name"
    t.string   "user_slug"
    t.integer  "user_id"
    t.text     "filter",        default: "{}", null: false
    t.integer  "visits",        default: 0,    null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "official_slug"
    t.index ["official_slug"], name: "index_filters_on_official_slug", unique: true, using: :btree
    t.index ["sid"], name: "index_filters_on_sid", unique: true, using: :btree
    t.index ["user_id"], name: "index_filters_on_user_id", using: :btree
    t.index ["user_slug"], name: "index_filters_on_user_slug", using: :btree
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "name"
    t.string   "name_slug"
    t.float    "playtime_mean"
    t.float    "playtime_median"
    t.float    "playtime_sd"
    t.float    "playtime_rsd"
    t.string   "playtime_ils"
    t.float    "playtime_mean_ftb"
    t.float    "playtime_median_ftb"
    t.string   "sysreq_video_tokens",  default: "", null: false
    t.integer  "sysreq_video_index"
    t.integer  "sysreq_index_centile"
    t.integer  "steam_game_id"
    t.integer  "lowest_steam_price"
    t.integer  "steam_discount"
    t.string   "tags"
    t.index ["steam_game_id"], name: "index_games_on_steam_game_id", using: :btree
  end

  create_table "gpus", force: :cascade do |t|
    t.string  "name"
    t.integer "value",          null: false
    t.string  "tokenized_name"
    t.index ["tokenized_name"], name: "index_gpus_on_tokenized_name", using: :btree
  end

  create_table "steam_games", force: :cascade do |t|
    t.integer  "steam_id",                           null: false
    t.string   "name"
    t.string   "tags"
    t.string   "genre"
    t.text     "summary"
    t.datetime "released_at"
    t.string   "thumbnail"
    t.text     "videos"
    t.text     "images"
    t.integer  "price"
    t.integer  "sale_price"
    t.integer  "reviews_ratio"
    t.integer  "reviews_count"
    t.integer  "positive_reviews_count"
    t.integer  "negative_reviews_count"
    t.text     "positive_reviews"
    t.text     "negative_reviews"
    t.integer  "dlc_count"
    t.integer  "achievements_count"
    t.string   "audio_languages"
    t.string   "subtitles_languages"
    t.integer  "metacritic"
    t.string   "esrb_rating"
    t.boolean  "early_access"
    t.text     "system_requirements"
    t.integer  "players",                default: 0, null: false
    t.integer  "controller_support",     default: 0, null: false
    t.integer  "features",               default: 0, null: false
    t.integer  "platforms",              default: 0, null: false
    t.integer  "vr_platforms",           default: 0, null: false
    t.integer  "vr_mode",                default: 0, null: false
    t.integer  "vr_controllers",         default: 0, null: false
    t.datetime "game_scraped_at"
    t.datetime "list_scraped_at"
    t.datetime "reviews_scraped_at"
  end

  create_table "sysreq_tokens", force: :cascade do |t|
    t.string   "name",                          null: false
    t.integer  "value"
    t.integer  "token_type",    default: 0,     null: false
    t.integer  "games_count",   default: 0,     null: false
    t.boolean  "year_analysis", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "linked_to"
    t.integer  "source",        default: 0,     null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_tags_on_name", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_admin",               default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "games", "steam_games"
end
