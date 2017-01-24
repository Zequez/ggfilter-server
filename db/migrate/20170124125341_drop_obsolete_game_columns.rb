class DropObsoleteGameColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :games, :playtime_ils
    remove_column :games, :sysreq_video_tokens
    remove_column :games, :sysreq_video_index
    remove_column :games, :sysreq_index_centile
    remove_column :games, :lowest_steam_price
    remove_column :games, :steam_discount
    remove_column :games, :sysreq_video_tokens_values
  end
end
