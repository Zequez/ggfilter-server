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
