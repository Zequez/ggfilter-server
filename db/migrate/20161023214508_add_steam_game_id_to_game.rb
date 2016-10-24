class AddSteamGameIdToGame < ActiveRecord::Migration[5.0]
  def change
    add_reference :games, :steam_game, foreign_key: true
  end
end
