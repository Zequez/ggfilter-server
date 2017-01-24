class AddVrOnlyToSteamGames < ActiveRecord::Migration[5.0]
  def change
    add_column :steam_games, :vr_only, :boolean, default: false, null: false
  end
end
