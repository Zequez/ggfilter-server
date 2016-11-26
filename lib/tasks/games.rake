namespace :games do
  desc 'Re-process the games'
  task :reprocess => :environment do
    Game.process_steam_game_data
  end

  desc 'Digest the system requirements text into tokens on the games'
  task :digest_system_requirements => :environment do
    Game.digest_system_requirements
  end

  desc 'Compute system requirements index centiles'
  task :compute_sysreq_index_centiles => :environment do
    Game.compute_sysreq_index_centiles
  end
end
