class AddCommunityHubIdToSteamGames < ActiveRecord::Migration[5.0]
  def change
    add_column :steam_games, :community_hub_id, :integer
  end
end
