class NormalizedGamePrices < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :steam_price, :integer
    add_column :games, :steam_price_regular, :integer
    add_column :games, :steam_price_discount, :integer
    
    add_column :games, :oculus_price, :integer
    add_column :games, :oculus_price_regular, :integer
    add_column :games, :oculus_price_discount, :integer
  end
end
