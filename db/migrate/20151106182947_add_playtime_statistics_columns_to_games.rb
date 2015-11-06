class AddPlaytimeStatisticsColumnsToGames < ActiveRecord::Migration
  def change
    add_column :games, :playtime_mean, :float
    add_column :games, :playtime_median, :float
    add_column :games, :playtime_sd, :float
    add_column :games, :playtime_rsd, :float
    add_column :games, :playtime_ils, :string
  end
end
