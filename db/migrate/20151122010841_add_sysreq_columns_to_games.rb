class AddSysreqColumnsToGames < ActiveRecord::Migration
  def change
    add_column :games, :sysreq_video_tokens, :string, default: '', null: false
    add_column :games, :sysreq_video_index, :integer
  end
end
