class SteamGameMigration < ActiveRecord::Migration
  def change
    create_table :steam_games do |t|
      # Game data
      t.integer :steam_id, null: false
      t.string :name
      t.string :tags
      t.string :genre
      t.text :summary
      t.datetime :released_at

      # Media
      t.string :thumbnail
      t.text :videos
      t.text :images

      # Price
      t.integer :price
      t.integer :sale_price

      # Reviews
      t.integer :reviews_ratio
      t.integer :reviews_count
      t.integer :positive_reviews_count
      t.integer :negative_reviews_count
      t.text :positive_reviews
      t.text :negative_reviews


      # Other data
      t.integer :dlc_count
      t.integer :achievements_count
      t.string :audio_languages
      t.string :subtitles_languages
      t.integer :metacritic
      t.string :esrb_rating
      t.boolean :early_access
      t.text :system_requirements

      # Flag values
      t.integer :players, default: 0, null: false
      t.integer :controller_support, default: 0, null: false
      t.integer :features, default: 0, null: false
      t.integer :platforms, default: 0, null: false
      t.integer :vr_platforms, default: 0, null: false
      t.integer :vr_mode, default: 0, null: false
      t.integer :vr_controllers, default: 0, null: false

      # Scraping dates
      t.datetime :game_scraped_at
      t.datetime :list_scraped_at
      t.datetime :reviews_scraped_at
    end
  end
end
