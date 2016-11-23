class AddNewStuffToSteamGame < ActiveRecord::Migration[5.0]
  def change
    add_column :steam_games, :text_release_date, :string
    add_column :steam_games, :developer, :string
    add_column :steam_games, :publisher, :string
    add_index :steam_games, :steam_id, unique: true
  end
end
