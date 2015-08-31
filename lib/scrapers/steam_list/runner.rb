# Responsabilities:
#  - Load the required games from the database
#  - Perform the scraping of the games with the URLs and the processors
#  - Save the games
#  - Report any issues like invalid data

class Scrapers::SteamList::Runner < Scrapers::BaseRunner
  self.options = {
    on_sale: false,
    all_games_url: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1',
    on_sale_url: 'http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&page=1&specials=1'
  }

  def run
    url = sale? ? options[:on_sale_url] : options[:all_games_url]
    @on_sale_ids = []
    @loader = Scrapers::Loader.new(url, Scrapers::SteamList::PageProcessor)
    @loader.scrap do |data|
      data_process(data, Game.find_by_steam_id(data[:id]))
    end

    if sale?
      Game.where.not(id: @on_sale_ids).update_all(steam_sale_price: nil)
    end
  end

  def data_process(data, game)
    processor = Scrapers::SteamList::DataProcessor.new(data, game)
    game = processor.process
    game.save!
    @on_sale_ids.push(game.id) if game.steam_sale_price
  end

  def sale?
    @options[:on_sale]
  end
end
