class ReplaceAllFilterEncodedFieldsWithASingleEncodedField < ActiveRecord::Migration[5.0]
  def change
    # OK I changed my mind, but the name of the migration stays

    remove_column :filters, :columns
    remove_column :filters, :controls
    remove_column :filters, :filters
    remove_column :filters, :config

    add_column :filters, :controls_list, :text, default: '[]', null: false
    add_column :filters, :controls_hl_mode, :text, default: '{}', null: false
    add_column :filters, :controls_config, :text, default: '{}', null: false
    add_column :filters, :columns_list, :text, default: '[]', null: false
    add_column :filters, :columns_config, :text, default: '{}', null: false
    # add_column :filters, :sorting, :text, default: '{}', null: false
    add_column :filters, :global_config, :text, default: '{}', null: false
  end
end
