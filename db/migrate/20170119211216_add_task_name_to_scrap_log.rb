class AddTaskNameToScrapLog < ActiveRecord::Migration[5.0]
  def change
    add_column :scrap_logs, :task_name, :string, null: false, default: ''
  end
end
