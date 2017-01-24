class AddSysreqGpuToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :sysreq_gpu_string, :string
    add_column :games, :sysreq_gpu_tokens, :string
  end
end
