class AddFlagsToGame < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :players, :integer, default: 0, null: false
    add_column :games, :controllers, :integer, default: 0, null: false
    add_column :games, :vr_modes, :integer, default: 0, null: false
    add_column :games, :vr_platforms, :integer, default: 0, null: false
    add_column :games, :gamepad, :integer, default: 0, null: false
  end
end
