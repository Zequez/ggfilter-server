class AddStoreAvailabilityToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :stores, :integer, default: 0, null: false
  end
end
