class ScrapingDirector
  class << self
    def scrap_steam_list
      Scrapers::Steam::List::Runner.new(resource_class: SteamGame).run
    end

    def scrap_steam_list_on_sale
      Scrapers::Steam::List::Runner.new(on_sale: true, resource_class: SteamGame).run
    end

    def scrap_steam_games
      steam_games = SteamGame.get_for_game_scraping
      Scrapers::Steam::Game::Runner.new(resources: steam_games).run
    end

    def scrap_steam_reviews
      steam_games = SteamGame.get_for_reviews_scraping
      # steam_games = SteamGame.where(steam_id: 8870)
      # steam_games = SteamGame.where(steam_id: [439260, 449940, 388390, 392190])
      Scrapers::Steam::Reviews::Runner.new(resources: steam_games).run
    end

    def scrap_benchmarks
      Scrapers::Benchmarks::Runner.new(resource_class: Gpu).run
    end
  end
end
