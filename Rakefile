# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :karma do
  desc 'Run JS tests with Karma'
  task :run do
    # Precompile assets and use that instead of the server and run Karma on single-run
  end

  desc 'Watch JS files with Karma and run tests when they change'
  task :watch do
    pid = spawn('rails s -p 2332')
    at_exit{ Process.kill 'HUP', pid }
    sleep(3)
    exec('karma start karma.config.js')
  end
end

namespace :sysreq do
  desc 'Run SysreqToken.analyze_games'
  task :analyze => :environment do
    SysreqToken.analyze_games
  end

  desc 'Remove Sysreqs without games'
  task :clean => :environment do
    SysreqToken.where(games_count: 0).delete_all
  end

  desc 'Try to match the Sysreq with the GPUs'
  task :match_gpus => :environment do
    SysreqToken.values_from_gpus_benchmarks!
  end

  desc 'Link the wildcard GPU names like 8xxx to 8800 and 8500'
  task :link_wildcards => :environment do
    SysreqToken.link_wildcards!
  end

  desc 'Infer values from existing relationships'
  task :infer_values => :environment do
    SysreqToken.infer_values!
  end
end

namespace :games do
  desc 'Re-save the games'
  task :resave => :environment do
    Game.find_in_batches(batch_size: 250).with_index do |games, i|
      puts "Saving #{i} batch"
      ActiveRecord::Base.transaction do
        games.each do |game|
          game.compute_values true
          game.save!
        end
      end
    end
  end
end
