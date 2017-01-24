class AddVrOnlyToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :vr_only, :boolean, default: false, null: false
  end
end
