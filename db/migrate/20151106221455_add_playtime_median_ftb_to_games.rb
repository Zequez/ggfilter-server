class AddPlaytimeMedianFtbToGames < ActiveRecord::Migration
  def change
    rename_column :games, :playtime_ftb, :playtime_mean_ftb
    add_column :games, :playtime_median_ftb, :float
  end
end
