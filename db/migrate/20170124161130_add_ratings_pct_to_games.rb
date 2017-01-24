class AddRatingsPctToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :ratings_pct, :integer
  end
end
