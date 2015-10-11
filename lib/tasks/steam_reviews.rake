namespace :scrap do
  namespace :steam_reviews do
    desc 'Scrap Steam game reviews from their reviews page'
    task :all, [:game] => :environment do |t, args|
      game = args[:game]
      if game
        if game =~ /^\d+$/
          games = [Game.find_by_steam_id(Integer(game))]
        else
          games = Game.filter_by_name(value: game, filter: true)
        end
      else
        games = Game.get_for_steam_reviews_scraping
      end

      Scrapers::SteamReviews::Runner.new(games: games, continue_with_errors: true).run
    end
  end
end
