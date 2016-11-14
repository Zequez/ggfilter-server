namespace :sysreq do
  desc 'Remove all SysreqTokens'
  task :delete_all => :environment do
    SysreqToken.all.delete_all
  end

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

  desc 'Infer lacking resolution values from already-inferred resolutions'
  task :infer_projected_values => :environment do
    SysreqToken.infer_projected_values!
  end

  desc 'Analyze, match GPUs, link wildcards, infer values, and infer projected values'
  task :all => [:analyze, :match_gpus, :infer_values, :infer_projected_values]
end
