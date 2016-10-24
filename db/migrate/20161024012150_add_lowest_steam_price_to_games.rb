class AddLowestSteamPriceToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :lowest_steam_price, :integer
  end
end
