class AddReleasedAtToOculusGames < ActiveRecord::Migration[5.0]
  def change
    add_column :oculus_games, :released_at, :datetime
  end
end
