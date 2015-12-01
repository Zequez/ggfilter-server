class CreateSysreqTokens < ActiveRecord::Migration
  def change
    create_table :sysreq_tokens do |t|
      t.string :name, null: false
      t.integer :value
      t.integer :type, default: 0, null: false
      t.integer :games_count, default: 0, null: false
      t.boolean :year_analysis, default: false, null: false
      t.timestamps null: false
    end
  end
end
