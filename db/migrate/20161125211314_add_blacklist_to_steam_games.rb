class AddBlacklistToSteamGames < ActiveRecord::Migration[5.0]
  def change
    add_column :steam_games, :blacklist, :boolean, null: false, default: false
  end
end
