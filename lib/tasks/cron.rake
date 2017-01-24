desc 'Helper task to disable Rails, ActiveRecord and Ethon logging'
task :nolog do
  dev_null = Logger.new('/dev/null')
  ActiveRecord::Base.logger = dev_null
  Ethon.logger = dev_null
  Rails.logger = dev_null
end

namespace :cron do
  desc 'Hourly except 00:00 UTC'
  task :hourly_heroku do
    if Time.now.utc.hour != 0
      Rake::Task['cron:hourly'].invoke
    end
  end

  desc 'Hourly cron that runs quick tasks and scrapings'
  task :hourly => [
      'nolog',
      'scrap:steam_list_on_sale',
      'scrap:steam_games',
      'scrap:steam_reviews',
      'scrap:oculus',
      'compute_all_globals'
  ]

  desc 'Daily cron that runs all the tasks and deep scrapings'
  task :daily => [
    'nolog',
    'scrap:benchmarks',
    'scrap:steam_list',
    'scrap:steam_games',
    'scrap:steam_reviews',
    'scrap:oculus',
    'compute_all_globals'
  ]
end
