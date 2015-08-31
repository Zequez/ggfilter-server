# Integration test incoming!

describe Scrapers::SteamList::Runner, cassette: true, type: :steam_list do
  klass = Scrapers::SteamList::Runner

  it 'should accept options as initializer' do
    runner = klass.new(all_games_url: 'potato', on_sale_url: 'salad')
    expect(runner.options).to eq({
      all_games_url: 'potato',
      on_sale_url: 'salad',
      on_sale: false
    })
  end

  context 'all new data' do
    it 'should scrap with the Loader and save all new games' do
      runner = klass.new(all_games_url: steam_list_url('k'))
      runner.run
      expect(Game.all.count).to eq 150
      game = Game.find_by_name('XCOM: Enemy Unknown')
      expect(game).to_not eq nil
      expect(game.platforms).to match_array [:mac, :win, :linux]
      expect(game.released_at).to be_within(1.day).of Time.parse('8 Oct, 2012')
      expect(game.steam_reviews_count).to be_within(100).of 23828
      expect(game.steam_reviews_ratio).to eq 95
      expect(game.steam_thumbnail).to eq 'http://cdn.akamai.steamstatic.com/steam/apps/200510/capsule_sm_120.jpg?t=1413482568'
      expect(game.steam_id).to eq 200510
    end
  end

  context 'some repeated contents' do
    it 'should update the existing games' do
      game = create :game, steam_id: 200510, name: 'Potato Simulator 2015', released_at: 1.month.ago
      runner = klass.new(all_games_url: steam_list_url('k'))
      runner.run
      expect(Game.all.count).to eq 150
      game.reload
      expect(game.name).to eq 'XCOM: Enemy Unknown'
      expect(game.released_at).to be_within(1.day).of Time.parse('8 Oct, 2012')
    end
  end

  context 'with the on_sale option' do
    it 'should use the on_sale_url URL instead and remove the sales of all other games' do
      game = create :game, steam_id: 123123, steam_sale_price: 123, steam_price: 300
      runner = klass.new(on_sale_url: steam_list_url('p', 1, true), all_games_url: '', on_sale: true)
      runner.run
      expect(Game.all.count).to eq 15
      game.reload
      expect(game.steam_sale_price).to eq nil
    end
  end
end
