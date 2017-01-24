class ChangeOculusIdToString < ActiveRecord::Migration[5.0]
  def change
    change_column :oculus_games, :oculus_id, :string, default: '', null: false
  end
end
