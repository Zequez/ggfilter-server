class AddRatingsToGame < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :ratings_count, :integer
    add_column :games, :positive_ratings_count, :integer
    add_column :games, :negative_ratings_count, :integer
    add_column :games, :ratings_ratio, :integer
  end
end
