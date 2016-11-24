class AddDefaultToSteamGameSerializedValues < ActiveRecord::Migration[5.0]
  def change
    change_column :steam_games, :tags, :string, default: '[]', null: false
    change_column :steam_games, :videos, :text, default: '[]', null: false
    change_column :steam_games, :images, :text, default: '[]', null: false
    change_column :steam_games, :positive_reviews, :text, default: '[]', null: false
    change_column :steam_games, :negative_reviews, :text, default: '[]', null: false
    change_column :steam_games, :audio_languages, :string, default: '[]', null: false
    change_column :steam_games, :subtitles_languages, :string, default: '[]', null: false
  end
end
