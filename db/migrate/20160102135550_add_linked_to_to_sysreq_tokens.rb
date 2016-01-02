class AddLinkedToToSysreqTokens < ActiveRecord::Migration
  def change
    add_column :sysreq_tokens, :linked_to, :string
  end
end
