class AddImagesVideosThumbnailToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :images, :text
    add_column :games, :videos, :text
    add_column :games, :thumbnail, :string
  end
end
