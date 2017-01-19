namespace :clean do
  desc 'Clean scrap logs older than 1 week'
  task :scrap_logs => :environment do
    ScrapLog.clean_logs
  end
end
