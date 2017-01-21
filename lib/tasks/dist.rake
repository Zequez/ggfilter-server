def read_gemfile_lock_dep_hash(name)
  m = File.read('Gemfile.lock').match(
    /revision: ([^\s]+)[^:]+:[^:]+#{name} \(([^\)]*)\)/m
  )
  m[2] + '-' + m[1].split(//).last(5).join
end

namespace :dist do
  desc 'Update Client dependency'
  task :update_client do
    `bundle update ggfilter_client`
    hash = read_gemfile_lock_dep_hash('ggfilter_client')
    `git add Gemfile.lock && git commit -m 'Updated Client #{hash}'`
  end

  desc 'Update Scrapers dependencies'
  task :update_scrapers do
    `bundle update scrapers`
    hash = read_gemfile_lock_dep_hash('scrapers')
    `git add Gemfile.lock && git commit -m 'Updated Scrapers #{hash}'`
  end

  desc 'Deploy to Heroku'
  task :deploy do
    `git push heroku master && heroku rake db:migrate && heroku restart`
  end

  desc 'Update deps and deploy'
  task :update_and_deploy => [:update_client, :update_scrapers, :deploy]
end
