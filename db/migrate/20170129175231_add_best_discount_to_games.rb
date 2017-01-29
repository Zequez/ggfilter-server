class AddBestDiscountToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :best_discount, :integer
  end
end
