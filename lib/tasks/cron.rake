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
      'scrap:steam:list_on_sale',
      'scrap:steam:games',
      'scrap:steam:reviews'
  ]#.each{ |task| Rake::Task[task].invoke }

  desc 'Daily cron that runs all the tasks and deep scrapings'
  task :daily => [
    'nolog',
    'scrap:benchmarks',
    'scrap:steam:list',
    'scrap:steam:games',
    'scrap:steam:reviews',
    'sysreq:all',
    'games:compute_sysreq_index_centiles'
  ]
end
