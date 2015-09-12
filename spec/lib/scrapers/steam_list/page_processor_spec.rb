describe Scrapers::SteamList::PageProcessor, cassette: true, type: :steam_list do
  def processor_class; Scrapers::SteamList::PageProcessor end

  def self.attributes_subject(page, name)
    subject do
      scrap(steam_list_url(page)).map do |h|
        if name.kind_of? Array
          name.map{|n| h[n]}
        else
          h[name]
        end
      end
    end
  end

  def self.specific_subject(page, options = {})
    group_run = options[:group] || false
    game_number = options[:n] || 0
    group_result = nil
    subject do
      group_result = nil unless group_run
      group_result ||= scrap(steam_list_url(page))[game_number]
    end
  end

  describe 'URL detection' do
    it 'should detect the Steam search result URLs' do
      url = steam_list_url(1)
      expect(url).to match processor_class.regexp
    end

    it 'should not detect non-steam search result URLs' do
      url = "http://store.steampowered.com/search"
      expect(url).to_not match processor_class.regexp
    end
  end

  describe 'loading multiple pages' do
    it 'should call the block given with all the next pages' do
      url1 = steam_list_url('civilization', 1)
      add_to_queue = lambda {|url|}
      (2..10).each do |n|
        expect(add_to_queue).to receive(:call).with(steam_list_url('civilization', n))
      end
      scrap(url1, &add_to_queue)
    end
  end

  describe ':id' do
    context 'regular page' do
      attributes_subject('potato', :id)

      it{ is_expected.to eq [
        219910,363600,328500,319910,374830,374640,356200
      ] }
    end
  end

  describe ':name' do
    context 'regular page' do
      attributes_subject(1, :name)

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

  describe ':price && :sale_price' do
    context 'regular page without sales' do
      attributes_subject(1, :price)

      it { is_expected.to eq [
        399,399,499,999,999,999,599,499,699,499,1499,299,299,299,499,999,0,299,999,999,999,1499,2499,699,599
      ] }
    end

    context 'page with items on sale' do
      specific_subject('1954 Alcatraz', group: true)
      its([:price]) { is_expected.to eq 1999 }
      its([:sale_price]) { is_expected.to eq 199 }
    end

    context 'empty price' do
      specific_subject('200% Mixed Juice!', group: true)
      its([:price]) { is_expected.to eq 0 }
      its([:sale_price]) { is_expected.to eq nil }
    end
  end

  describe ':released_at' do
    context 'regular release date' do
      specific_subject('1954 Alcatraz')
      its([:released_at]) { is_expected.to be_within(1.hour).of Time.parse('Mar 11, 2014') }
    end

    context 'empty release date' do
      specific_subject('LUXOR Mah Jong')
      its([:released_at]) { is_expected.to eq nil }
    end

    context 'non-date release date' do
      specific_subject('march of industry')
      its([:released_at]) { is_expected.to eq nil }
    end
  end

  describe ':platforms' do
    context 'all 3 platforms' do
      specific_subject('race the sun')
      its([:platforms]) { are_expected.to match_array [:mac, :win, :linux] }
    end
  end

  describe ':reviews_count, :reviews_ratio' do
    context 'a simple page' do
      attributes_subject('race the sun', [:reviews_count, :reviews_ratio])

      it { is_expected.to eq [
        [3578, 94],
        [272, 26],
        [99, 86],
        [34, 61],
        [162, 67]
      ] }
    end
  end

  describe ':thumbnail' do
    context 'a simple page' do
      attributes_subject('race the sun', :thumbnail)

      it { is_expected.to eq [
        "http://cdn.akamai.steamstatic.com/steam/apps/253030/capsule_sm_120.jpg?t=1440181925",
        "http://cdn.akamai.steamstatic.com/steam/apps/246940/capsule_sm_120.jpg?t=1413426525",
        "http://cdn.akamai.steamstatic.com/steam/apps/293880/capsule_sm_120.jpg?t=1435972880",
        "http://cdn.akamai.steamstatic.com/steam/apps/336630/capsule_sm_120.jpg?t=1418112532",
        "http://cdn.akamai.steamstatic.com/steam/apps/253880/capsule_sm_120.jpg?t=1440146509"
      ] }
    end
  end
end
