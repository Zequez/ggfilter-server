namespace :scrap do
  namespace :steam_list do
    desc 'Scrap all the Steam games from the complete list'
    task :all => :environment do
      Scrapers::SteamList::Runner.new.run continue_with_errors: true
    end

    desc 'Scrap all the Steam games on sale'
    task :sale => :environment do
      Scrapers::SteamList::Runner.new(on_sale: true, continue_with_errors: true).run
    end
  end
end
