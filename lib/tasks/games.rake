namespace :games do
  # desc 'Re-save the games'
  # task :resave => :environment do
  #   Game.find_in_batches(batch_size: 250).with_index do |games, i|
  #     puts "Saving #{i} batch"
  #     ActiveRecord::Base.transaction do
  #       games.each do |game|
  #         game.save!
  #       end
  #     end
  #   end
  # end

  desc 'Compute system requirements index centiles'
  task :compute_sysreq_index_centiles => :environment do
    Game.compute_sysreq_index_centiles
  end
end
