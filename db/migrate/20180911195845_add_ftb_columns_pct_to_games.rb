class AddFtbColumnsPctToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :playtime_median_ftb_pct, :integer
    add_column :games, :playtime_mean_ftb_pct, :integer
  end
end
