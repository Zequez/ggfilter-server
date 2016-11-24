class AddDefaultToGameTags < ActiveRecord::Migration[5.0]
  def change
    change_column :games, :tags, :string, default: '[]', null: false
  end
end
