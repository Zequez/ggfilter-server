class AddPlaytimeFtbToGames < ActiveRecord::Migration
  def change
    add_column :games, :playtime_ftb, :float
  end
end
