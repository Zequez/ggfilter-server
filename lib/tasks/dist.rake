namespace :dist do
  desc 'Update the client and scrapers dependencies'
  task :update_deps do
    `bundle update ggfilter_client scrapers`
    `git add -A && git commit -m 'Updated Client/Scrapers'`
  end

  desc 'Deploy to Heroku'
  task :deploy => [:update_deps] do
    `git push heroku master && heroku rake db:migrate && heroku restart`
  end
end
