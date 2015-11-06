class AddSteamDiscountToGames < ActiveRecord::Migration
  def change
    add_column :games, :steam_discount, :integer
  end
end
