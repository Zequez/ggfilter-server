class ChangeFiltersControlsHlModeToArrayDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :filters, :controls_hl_mode, :text, default: '[]', null: false
  end
end
