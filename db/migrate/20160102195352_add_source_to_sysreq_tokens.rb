class AddSourceToSysreqTokens < ActiveRecord::Migration
  def change
    add_column :sysreq_tokens, :source, :integer, default: 0, null: false
  end
end
