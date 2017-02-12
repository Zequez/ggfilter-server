class ChangeFiltersConfigsToParams < ActiveRecord::Migration[5.0]
  def change
    rename_column :filters, :controls_config, :controls_params
    rename_column :filters, :columns_config, :columns_params
  end
end
