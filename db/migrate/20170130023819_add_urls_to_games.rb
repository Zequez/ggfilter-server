class AddUrlsToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :urls, :text, default: '{}', null: false
  end
end
