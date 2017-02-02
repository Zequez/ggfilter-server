class AddMoreStuffToFilter < ActiveRecord::Migration[5.0]
  def change
    add_column :filters, :filters, :text, default: '{}', null: false
    change_column :filters, :controls, :text, default: '[]', null: false
    add_column :filters, :config, :text, default: '{}', null: false
  end
end
