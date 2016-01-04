class AddSysreqIndexCentilesToGames < ActiveRecord::Migration
  def change
    add_column :games, :sysreq_index_centile, :integer
  end
end
