class AddLowestPriceToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :lowest_price, :integer
  end
end
