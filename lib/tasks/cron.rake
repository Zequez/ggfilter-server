namespace :cron do
  desc 'Hourly cron that runs quick tasks and scrapings'
  task :hourly => [
    'scrap:steam:list_on_sale',
    'scrap:steam:games',
    'scrap:steam:reviews'
  ]

  desc 'Daily cron that runs all the tasks and deep scrapings'
  task :daily => [
    'scrap:benchmarks',
    'scrap:steam:list',
    'scrap:steam:games',
    'scrap:steam:reviews',
    'sysreq:all',
    'games:compute_sysreq_index_centiles'
  ]
end
