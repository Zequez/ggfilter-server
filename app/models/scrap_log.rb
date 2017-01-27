# == Schema Information
#
# Table name: scrap_logs
#
#  id                  :integer          not null, primary key
#  started_at          :datetime         not null
#  finished_at         :datetime         not null
#  error               :boolean          default(FALSE), not null
#  msg                 :string           default(""), not null
#  task_name           :string           default(""), not null
#  scraper_finished_at :datetime
#

class ScrapLog < ApplicationRecord
  scope :get_for_cleanup, ->{ where('started_at < ?', 1.week.ago) }
  scope :for_index, ->{ order('started_at DESC') }

  def self.clean_logs
    get_for_cleanup.delete_all
  end

  def apply_report(report)
    self.finished_at = Time.now
    self.scraper_finished_at = report.finished_at
    self.error = report.errors?

    msgs = [report.scraper_report]
    msgs.push "#{report.errors.size} errors" if report.errors?
    msgs.push "#{report.warnings.size} warnings" if report.warnings?
    msgs.compact!

    self.msg = msgs.join(' | ')
  end
end
