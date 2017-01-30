class AddPricesToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :prices, :text, default: '{}', null: false
  end
end
