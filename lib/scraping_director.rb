class ScrapingDirector
  class << self
    def scrap_steam_list
      Scrapers::Steam::List::Runner.new.run
    end

    def scrap_steam_list_on_sale
      Scrapers::Steam::List::Runner.new(on_sale: true).run
    end

    def scrap_steam_games
      steam_games = SteamGame.get_for_game_scraping
      Scrapers::Steam::Game::Runner.new(resources: steam_games).run
    end

    def scrap_steam_reviews
      steam_games = SteamGame.get_for_reviews_scraping
      Scrapers::Steam::Reviews::Runner.new(resources: steam_games).run
    end

    def scrap_benchmarks
      Scrapers::Benchmarks::Runner.new.run
    end
  end
end
