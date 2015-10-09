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

ActiveRecord::Schema.define(version: 20151009051452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
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
    t.integer  "platforms",                    default: 0, null: false
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
  end

end
