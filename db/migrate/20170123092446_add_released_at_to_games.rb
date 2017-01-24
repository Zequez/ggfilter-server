class AddReleasedAtToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :released_at, :datetime
  end
end
