namespace :scrap do
  desc 'Scrap GPUs benchmarks from videocardbenchmark.net'
  task :benchmarks => :environment do
    Scrapers::Benchmarks::Runner.new.run
  end
end
