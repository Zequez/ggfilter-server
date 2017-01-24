class AddPlatformsToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :platforms, :integer, default: 0, null: false
  end
end
