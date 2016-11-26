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
  task :all => [:analyze, :clean, :match_gpus, :infer_values, :infer_projected_values]

  desc 'Recreate GPUs names'
  task :gpu_recreate => [:environment] do
    Gpu.all.each(&:save!)
  end

  desc 'Digest the system requirements text into tokens on the games'
  task :games_digest => :environment do
    Game.digest_system_requirements
  end

  desc 'Compute system requirements index centiles'
  task :games_centiles => :environment do
    Game.compute_sysreq_index_centiles
  end

  desc 'All with games'
  task :all_all => [:gpu_recreate, :games_digest, :all, :games_centiles]
end
