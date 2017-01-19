class ScrapersDefinitions
  def steam_list
    Scrapers::Steam::List::Runner.new(resource_class: SteamGame)
  end

  def steam_list_on_sale
    Scrapers::Steam::List::Runner.new(on_sale: true, resource_class: SteamGame)
  end

  def steam_games
    steam_games = SteamGame.get_for_game_scraping.includes(:game)
    Scrapers::Steam::Game::Runner.new(resources: steam_games)
  end

  def steam_reviews
    steam_games = SteamGame.get_for_reviews_scraping.includes(:game)
    Scrapers::Steam::Reviews::Runner.new(resources: steam_games)
  end

  def benchmarks
    Scrapers::Benchmarks::Runner.new(resource_class: Gpu)
  end
end
