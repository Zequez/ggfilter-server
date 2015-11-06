class AddLowestSteamPriceToGames < ActiveRecord::Migration
  def change
    add_column :games, :lowest_steam_price, :integer
  end
end
