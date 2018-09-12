class AddPctColumnsToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :playtime_mean_pct, :integer
    add_column :games, :playtime_median_pct, :integer
    add_column :games, :playtime_sd_pct, :integer
    add_column :games, :playtime_rsd_pct, :integer
    add_column :games, :ratings_count_pct, :integer
    add_column :games, :ratings_ratio_pct, :integer
  end
end
