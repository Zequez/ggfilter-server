class GpuMigration < ActiveRecord::Migration
  def change
    create_table :gpus do |t|
      t.string :name
      t.integer :value, null: false
    end
  end
end
