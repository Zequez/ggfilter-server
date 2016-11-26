class AddSysreqVideoTokensValuesToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :sysreq_video_tokens_values, :text
  end
end
