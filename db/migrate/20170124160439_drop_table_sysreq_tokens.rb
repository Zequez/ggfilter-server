class DropTableSysreqTokens < ActiveRecord::Migration[5.0]
  def change
    drop_table :sysreq_tokens
  end
end
