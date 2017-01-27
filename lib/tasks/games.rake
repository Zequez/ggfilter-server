namespace :games do
  desc 'Re-process the games'
  task :recompute => :environment do
    Game.re_compute_all
  end

  desc 'Compute all the data that requires loading all the games at the same time'
  task :compute_all_globals => :environment do
    Game.compute_all_globals
  end

  desc 'Compute percentiles'
  task :compute_percentiles => :environment do
    Game.compute_percentiles
  end
end
