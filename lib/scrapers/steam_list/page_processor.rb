class Scrapers::SteamList::PageProcessor < Scrapers::BasePageProcessor
  regexp %r{^http://store\.steampowered\.com/search/results}

  def process_page
    data = []

    @doc.search('.search_result_row').each do |a|
      game = {}

      game[:steam_id] = read_id(a)
      game[:steam_name] = a.search('.title').text.strip
      game[:steam_price], game[:steam_sale_price] = read_prices(a)

      data << game
    end

    data
  end

  def read_id(a)
    id = a['href'].scan(/app\/([0-9]+)/).flatten.first
    id ? Integer(id) : nil
  end

  def read_prices(a)
    text = a.search('.search_price').text
    if text
      price, sale_price = text.strip.scan(/\$\d+(?:\.\d+)?|[^\0-9]+/).flatten
      price = price ? parse_price(price) : 0
      sale_price = parse_price(sale_price)

      # sale_price = a.search('.search_price strike').empty?

      # steam_price = parse_price price
      # steam_sale_price = parse_price striked_price

      [price, sale_price]
    else
      [nil, nil]
    end
  end

  def parse_price(price)
    return nil if price.nil?

    price = price.strip.sub(/^\$/, '')

    if price =~ /[[:digit:]]+(\.[[:digit:]]+)?/
      price = Integer((Float(price) * 100).round)
    else
      price = price.downcase
      means_its_free = ['free to play', 'play for free', 'free', 'third party', 'open weekend']
      if price =~ /free/ or means_its_free.include? price
        price = 0
      else
        price = nil
      end
    end

    price
  end
end
