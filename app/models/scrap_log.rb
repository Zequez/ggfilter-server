# == Schema Information
#
# Table name: scrap_logs
#
#  id          :integer          not null, primary key
#  started_at  :datetime         not null
#  finished_at :datetime         not null
#  scraper     :string           not null
#  error       :boolean          default(FALSE), not null
#  msg         :string           default(""), not null
#  task_name   :string           default(""), not null
#

class ScrapLog < ApplicationRecord
  scope :get_for_cleanup, ->{ where('started_at < ?', 1.week.ago) }
  scope :for_index, ->{ order('started_at DESC') }

  def self.clean_logs
    get_for_cleanup.delete_all
  end

  def self.build_from_report(scrap_report, task_name = nil)
    new(
      started_at: scrap_report.started_at,
      finished_at: scrap_report.finished_at,
      msg: (scrap_report.error? ?
        scrap_report.exception.message
        : scrap_report.scraper_report) || '',
      error: scrap_report.error?,
      scraper: scrap_report.scraper_name,
      task_name: task_name || scrap_report.scraper_name
    )
  end
end
