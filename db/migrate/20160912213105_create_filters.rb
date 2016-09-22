class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :sid, null: false, unique: true
      t.string :name
      t.string :slug
      t.references :user, index: true, foreign_key: true
      t.boolean :official, default: false, null: false
      t.text :filter, default: '{}', null: false
      t.integer :visits, default: 0, null: false

      t.timestamps null: false
    end

    add_index :filters, :sid
    add_index :filters, :slug
  end
end
