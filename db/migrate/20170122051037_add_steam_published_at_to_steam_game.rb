class AddSteamPublishedAtToSteamGame < ActiveRecord::Migration[5.0]
  def change
    add_column :steam_games, :steam_published_at, :datetime
  end
end
