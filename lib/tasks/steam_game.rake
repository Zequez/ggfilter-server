namespace :scrap do
  namespace :steam_game do
    desc 'Scrap Steam games from their app page'
    task :all => :environment do
      games = Game.get_for_steam_game_scraping
      Scrapers::SteamGame::Runner.new(games: games, continue_with_errors: true).run
    end
  end
end
