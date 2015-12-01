class RenameSysreqTokenTypeColumnToTokenType < ActiveRecord::Migration
  def change
    rename_column :sysreq_tokens, :type, :token_type
  end
end
