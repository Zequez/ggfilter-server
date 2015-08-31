# Output
# Array of
#  :id
#  :name
#  :price
#  :sale_price
#  :released_at
#  :platforms
#  :reviews_count
#  :reviews_ratio
#  :thumbnail

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
      game[:platforms] = read_platforms(a)
      game[:reviews_count], game[:reviews_ratio] = read_reviews(a)
      game[:thumbnail] = read_thumbnail(a)

      data << game
    end

    pagination = @doc.search('.search_pagination_right')
    if pagination.text.strip =~ /^1\b/ # if we are parsing the first page
      last_page_e = pagination.search('a:not(.pagebtn)').last
      if last_page_e
        last_page_link = last_page_e['href'].sub(%r{/search/\?}, '/search/results?')
        last_page_number = Integer(last_page_link.scan(/page=(\d+)/).flatten.first)
        (2..last_page_number).each do |n|
          page_link = @url.sub("page=1", "page=#{n}")
          add_to_queue page_link
        end
      end
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

  def read_platforms(a)
    platforms = []
    platforms.push(:win) if a.search('.platform_img.win').first
    platforms.push(:mac) if a.search('.platform_img.mac').first
    platforms.push(:linux) if a.search('.platform_img.linux').first
    platforms
  end

  def read_reviews(a)
    reviews_e = a.search('.search_review_summary').first
    if reviews_e
      tooltip = reviews_e['data-store-tooltip']
      tooltip.gsub(',', '').scan(/\d+/).map{|n| Integer(n)}.reverse
    else
      [nil, nil]
    end
  end

  def read_thumbnail(a)
    img_e = a.search('.search_capsule img').first
    img_e ? img_e['src'] : nil
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
