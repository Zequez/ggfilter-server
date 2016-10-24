class AddTagsToGame < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :tags, :string
  end
end
