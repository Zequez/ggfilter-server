describe Scrapers::SteamList::DataProcessor do
  klass = Scrapers::SteamList::DataProcessor

  it 'should copy the attributes from the data hash to the game' do
    game = create :game
    data = {
      id: 1234,
      name: 'Potato',
      price: 123,
      sale_price: 50,
      released_at: 1.week.ago,
      platforms: [:win, :mac, :linux],
      reviews_count: 1111,
      reviews_ratio: 95,
      thumbnail: 'http://imgur.com/rsarsa'
    }

    processor = klass.new(data, game)
    expect(processor.process).to eq game

    expect(game.steam_id).to eq 1234
    expect(game.steam_name).to eq 'Potato'
    expect(game.name).to eq 'Potato'
    expect(game.steam_price).to eq 123
    expect(game.steam_sale_price).to eq 50
    expect(game.released_at).to be_within(1.minute).of(1.week.ago)
    expect(game.platforms).to match_array [:win, :mac, :linux]
    expect(game.steam_reviews_count).to eq 1111
    expect(game.steam_reviews_ratio).to eq 95
    expect(game.steam_thumbnail).to eq 'http://imgur.com/rsarsa'

    expect(game.new_record?).to eq false
  end

  it "should build a new Game if it's nil" do
    data = {
      id: 1234,
      name: 'Potato',
      price: 123,
      sale_price: 50,
      released_at: 1.week.ago,
      platforms: [:win, :mac, :linux],
      reviews_count: 1111,
      reviews_ratio: 95,
      thumbnail: 'http://imgur.com/rsarsa'
    }

    processor = klass.new(data, nil)
    game = processor.process

    expect(game.steam_id).to eq 1234
    expect(game.steam_name).to eq 'Potato'
    expect(game.name).to eq 'Potato'
    expect(game.steam_price).to eq 123
    expect(game.steam_sale_price).to eq 50
    expect(game.released_at).to be_within(1.minute).of(1.week.ago)
    expect(game.platforms).to match_array [:win, :mac, :linux]
    expect(game.steam_reviews_count).to eq 1111
    expect(game.steam_reviews_ratio).to eq 95
    expect(game.steam_thumbnail).to eq 'http://imgur.com/rsarsa'

    expect(game.new_record?).to eq true
  end
end
