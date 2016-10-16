describe FilteringHelpers do
  # TODO: Convert it to a shared example...

  describe '.apply_filter' do
    it 'should create a new column with whether the row is highlighted' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.apply_filter(:name, {value: 'Galaxy', highlight: true})

      expect(games).to match_array [g1, g2]
      highlighted = games.map(&:hl_name)

      expect(highlighted).to match_array [true, false]
    end
  end

  it 'highlighting should work with string keys' do
    g1 = create :game, name: 'Potato'
    g2 = create :game, name: 'Galaxy'

    games = Game.apply_filter('name', {'value' => 'Galaxy', 'highlight' => true})

    expect(games).to match_array [g1, g2]
    highlighted = games.map(&:hl_name)

    expect(highlighted).to match_array [true, false]
  end

  it 'should work with highlight in combination with other filters' do
    g1 = create :game, name: 'Potato', steam_id: 1234
    g2 = create :game, name: 'Potasium', steam_id: 333
    _g3 = create :game, name: 'Galaxy', steam_id: 123

    games = Game
      .apply_filter(:name, {value: 'Pot', filter: true})
      .apply_filter(:steam_id, {value: 333, highlight: true})

    expect(games).to match_array [g1, g2]
    expect(games.map(&:hl_steam_id)).to match [false, true]
  end

  describe '.register_filter' do
    it 'should allow you to register a filter with a different column name' do
      params = {value: 'Hallo!'}
      expect(Game).to receive(:exact_filter).with(:name, params).and_return('name = "hello"')
      Game.register_filter(:wakawaka, :exact_filter, :name)
      Game.apply_filter(:wakawaka, params)
    end
  end
end
