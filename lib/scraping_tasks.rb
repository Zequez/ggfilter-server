require 'scraping_task'

module ScrapingTasks
  class SteamGames < ScrapingTask
    task_name 'steam_games'

    def scraper
      steam_ids = SteamGame.get_for_game_scraping.pluck(:steam_id)
      Scrapers::Steam::Game::Runner.new(steam_ids: steam_ids)
    end

    def save(output); end

    def partial_process(attrs)
      rescue_save_fail do
        SteamGame.from_game_scraper!(attrs)
          .propagate_to_game
      end
    end
  end

  class SteamGamesForce < SteamGames
    task_name 'steam_games_force'

    def scraper
      steam_ids = SteamGame.pluck(:steam_id)
      Scrapers::Steam::Game::Runner.new(steam_ids: steam_ids)
    end
  end

  class SteamList < ScrapingTask
    task_name 'steam_list'

    def scraper
      Scrapers::Steam::List::Runner.new(url: :all)
    end

    def save_each(attrs)
      SteamGame.from_list_scraper!(attrs)
        .propagate_to_game
    end
  end

  class SteamListOnSale < SteamList
    task_name 'steam_list_on_sale'

    def scraper
      Scrapers::Steam::List::Runner.new(url: :on_sale)
    end

    def after_save(games)
      on_sale_ids = games.map{ |g| g[:steam_id] }
      SteamGame.update_not_on_sale on_sale_ids
    end
  end

  class SteamReviews < ScrapingTask
    task_name 'steam_reviews'

    def scraper
      steam_ids = SteamGame.get_for_reviews_scraping.pluck(:steam_id)
      Scrapers::Steam::Reviews::Runner.new(steam_ids: steam_ids)
    end

    def save_each(attrs)
      SteamGame.from_reviews_scraper!(attrs)
        .propagate_to_game
    end
  end

  class OculusGames < ScrapingTask
    task_name 'oculus_games'

    def scraper
      Scrapers::Oculus::Runner.new
    end

    def save_each(attrs)
      OculusGame.from_scraper!(attrs)
        .propagate_to_game
    end
  end

  class Benchmarks < ScrapingTask
    task_name 'benchmarks'

    def scraper
      Scrapers::Benchmarks::Runner.new
    end

    def save_each(attrs)
      Gpu.from_scraper! attrs
    end
  end
end
