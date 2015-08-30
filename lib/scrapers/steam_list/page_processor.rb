# Output
# Array of
#  :id
#  :name
#  :price
#  :sale_price
#  :released_at

class Scrapers::SteamList::PageProcessor < Scrapers::BasePageProcessor
  regexp %r{^http://store\.steampowered\.com/search/results}

  def process_page
    data = []

    @doc.search('.search_result_row').each do |a|
      game = {}

      game[:id] = read_id(a)
      game[:name] = read_name(a)
      game[:price], game[:sale_price] = read_prices(a)
      game[:released_at] = read_released_at(a)

      data << game
    end

    data
  end

  def read_id(a)
    id = a['href'].scan(/app\/([0-9]+)/).flatten.first
    id ? Integer(id) : nil
  end

  def read_name(a)
    a.search('.title').text.strip
  end

  def read_prices(a)
    text = a.search('.search_price').text
    if text
      price, sale_price = text.strip.scan(/\$\d+(?:\.\d+)?|[^\0-9]+/).flatten
      price = price ? parse_price(price) : 0
      sale_price = parse_price(sale_price)
      [price, sale_price]
    else
      [nil, nil]
    end
  end

  def read_released_at(a)
    date = a.search('.search_released').text
    if date.blank?
      nil
    else
      begin
        Time.parse(a.search('.search_released').text)
      rescue ArgumentError
        nil
      end
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
