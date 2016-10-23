class ConsolidatedInitialMigration < ActiveRecord::Migration
  def change
    create_table "filters" do |t|
      t.string   "sid",                           null: false
      t.string   "name"
      t.string   "user_slug"
      t.integer  "user_id"
      t.text     "filter",        default: "{}",  null: false
      t.integer  "visits",        default: 0,     null: false
      t.datetime "created_at",                    null: false
      t.datetime "updated_at",                    null: false
      t.string   "official_slug"
    end

    add_index "filters", ["sid"], unique: true
    add_index "filters", ["official_slug"], unique: true
    add_index "filters", ["user_id"]
    add_index "filters", ["user_slug"]

    create_table "games" do |t|
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false

      t.string   "name"
      t.string   "name_slug"

      t.float    "playtime_mean"
      t.float    "playtime_median"
      t.float    "playtime_sd"
      t.float    "playtime_rsd"
      t.string   "playtime_ils"
      t.float    "playtime_mean_ftb"
      t.float    "playtime_median_ftb"

      t.string   "sysreq_video_tokens",          default: "", null: false
      t.integer  "sysreq_video_index"
      t.integer  "sysreq_index_centile"
    end

    create_table "sysreq_tokens" do |t|
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

    create_table "users" do |t|
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
    end

    add_index "users", ["email"], name: "index_users_on_email", unique: true
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
