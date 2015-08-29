class AddNameSlugToGames < ActiveRecord::Migration
  def change
    add_column :games, :name_slug, :string
  end
end
