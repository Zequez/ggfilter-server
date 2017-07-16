namespace :pull_db do
  desc 'Pull DB from production server into local environment'
  task :pull do
    Bundler.with_clean_env do
      `rm latest.dump`
      `heroku pg:backups:capture`
      `heroku pg:backups:download`
    end
  end

  desc 'Restore DB from dump'
  task :restore do
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U zequez -d ggfilter_development latest.dump`
  end
end
