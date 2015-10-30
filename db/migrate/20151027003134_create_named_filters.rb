class CreateNamedFilters < ActiveRecord::Migration
  def change
    create_table :named_filters do |t|
      t.string :name
      t.string :columns
      t.text :filters

      t.timestamps null: false
    end
  end
end
