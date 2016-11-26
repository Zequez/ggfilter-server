namespace :scrap do
  desc 'Scrap benchmarks'
  task :benchmarks => :environment do
    ScrapingDirector.scrap_benchmarks
  end

  namespace :steam do
    desc 'Scrap steam list'
    task :list => :environment do
      ScrapingDirector.scrap_steam_list
    end

    desc 'Scrap steam list on sale'
    task :list_on_sale => :environment do
      ScrapingDirector.scrap_steam_list_on_sale
    end

    desc 'Scrap steam games'
    task :games => [:environment, :nolog] do
      ScrapingDirector.scrap_steam_games
    end

    desc 'Scrap steam reviews'
    task :reviews => :environment do
      ScrapingDirector.scrap_steam_reviews
    end
  end
end
