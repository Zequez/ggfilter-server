describe Scrapers::SteamList::PageProcessor, cassette: true do
  def scrap(page_url)
    @scraper = Scrapers::Loader.new page_url, Scrapers::SteamList::PageProcessor
    @result = @scraper.scrap
  end

  def result_url(number_or_query)
    param = number_or_query.kind_of?(String) ? "term=#{number_or_query}" : "page=#{number_or_query}"
    "http://store.steampowered.com/search/results?category1=998&sort_by=Name&sort_order=ASC&category1=998&cc=us&v5=1&#{param}"
  end

  def self.attributes_subject(page, name)
    subject{ scrap(result_url(page)).map{|h| h[name]} }
  end

  def self.specific_subject(page, options = {})
    group_run = options[:group] || false
    game_number = options[:n] || 0
    group_result = nil
    subject do
      group_result = nil unless group_run
      group_result ||= scrap(result_url(page))[game_number]
    end
  end

  describe 'URL detection' do
    it 'should detect the Steam search result URLs' do
      url = result_url(1)
      expect{ scrap(url) }.to_not raise_error
    end

    it 'should not detect non-steam search result URLs' do
      url = "http://store.steampowered.com/search"
      expect{ scrap(url) }.to raise_error Scrapers::NoPageProcessorFoundError
    end
  end

  describe ':steam_id' do
    context 'regular page' do
      attributes_subject('potato', :steam_id)

      it{ is_expected.to eq [
        374830,219910,363600,356200,374640,328500,319910
      ] }
    end
  end

  describe ':steam_name' do
    context 'regular page' do
      attributes_subject(1, :steam_name)

      it{ is_expected.to eq [
        "\"Glow Ball\" - The billiard puzzle game",
        "//N.P.P.D. RUSH//- The milk of Ultraviolet",
        "//SNOWFLAKE TATTOO//",
        "0RBITALIS", "1... 2... 3... KICK IT! (Drop That Beat Like an Ugly Baby)",
        "10 Second Ninja", "10 Years After",
        "10,000,000",
        "100% Orange Juice",
        "1000 Amps",
        "1001 Spikes",
        "12 Labours of Hercules",
        "12 Labours of Hercules II: The Cretan Bull",
        "12 Labours of Hercules III: Girl Power",
        "140",
        "15 Days",
        "16 Bit Arena",
        "16bit Trader",
        "18 Wheels of Steel: American Long Haul",
        "18 Wheels of Steel: Extreme Trucker",
        "18 Wheels of Steel: Extreme Trucker 2",
        "1849",
        "1931: Scheherazade at the Library of Pergamum",
        "1942: The Pacific Air War", "1953 - KGB Unleashed"
      ] }
    end
  end

  describe ':steam_price && :steam_sale_price' do
    context 'regular page without sales' do
      attributes_subject(1, :steam_price)

      it { is_expected.to eq [
        399,399,499,999,999,999,599,499,699,499,1499,299,299,299,499,999,0,299,999,999,999,1499,2499,699,599
      ] }
    end

    context 'page with items on sale' do
      specific_subject('1954 Alcatraz', group: true)
      its([:steam_price]) { is_expected.to eq 1999 }
      its([:steam_sale_price]) { is_expected.to eq 199 }
    end

    context 'empty price' do
      specific_subject('200% Mixed Juice!', group: true)
      its([:steam_price]) { is_expected.to eq 0 }
      its([:steam_sale_price]) { is_expected.to eq nil }
    end
  end
end
