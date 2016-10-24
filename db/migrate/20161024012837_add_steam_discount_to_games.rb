class AddSteamDiscountToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :steam_discount, :integer
  end
end
