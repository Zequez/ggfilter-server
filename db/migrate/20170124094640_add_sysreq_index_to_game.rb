class AddSysreqIndexToGame < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :sysreq_index, :integer
    add_column :games, :sysreq_index_pct, :integer
  end
end
