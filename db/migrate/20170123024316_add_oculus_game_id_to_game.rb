class AddOculusGameIdToGame < ActiveRecord::Migration[5.0]
  def change
    add_reference :games, :oculus_game, foreign_key: true
  end
end
