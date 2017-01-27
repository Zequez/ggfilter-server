class AddScrapersFinishedAtToScrapLog < ActiveRecord::Migration[5.0]
  def change
    add_column :scrap_logs, :scraper_finished_at, :datetime
    remove_column :scrap_logs, :scraper
  end
end
