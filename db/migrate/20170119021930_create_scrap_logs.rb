class CreateScrapLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :scrap_logs do |t|
      t.datetime :started_at, null: false
      t.datetime :finished_at, null: false
      t.string :scraper, null: false
      t.boolean :error, default: false, null: false
      t.string :msg, default: '', null: false
    end
  end
end
