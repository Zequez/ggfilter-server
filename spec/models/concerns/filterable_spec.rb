describe Filterable do
  # TODO: Convert it to a shared example...

  describe '.apply_filter' do
    it 'should create a new column with whether the row is highlighted' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.apply_filter(:name, {value: 'Galaxy', hl: true})

      expect(games).to match_array [g1, g2]
      highlighted = games.map(&:hl_name)

      expect(highlighted).to eq [false, true]
    end
  end

  it 'highlighting should work with string keys' do
    g1 = create :game, name: 'Potato'
    g2 = create :game, name: 'Galaxy'

    games = Game.apply_filter('name', {'value' => 'Galaxy', 'hl' => true})

    expect(games).to eq [g1, g2]
    highlighted = games.map(&:hl_name)

    expect(highlighted).to eq [false, true]
  end

  it 'should work with highlight in combination with other filters' do
    g1 = create :game, name: 'Potato', lowest_price: 999
    g2 = create :game, name: 'Potassium', lowest_price: 500
    _g3 = create :game, name: 'Galaxy', lowest_price: 200

    games = Game
      .apply_filter(:name, {value: 'Pot'})
      .apply_filter(:lowest_price, {gt: 300, lt: 600, hl: true})

    expect(games).to eq [g1, g2]
    expect(games.map(&:hl_lowest_price)).to eq [false, true]
  end

  describe '.register_filter' do
    def register_and_get_filter(name, type, options, params)
      Game.register_filter(name, type, options)
      games = Game.apply_filter(name, params)
      games.map(&:attributes)
    end

    it 'should allow you to register a filter with a different column name'  do
      params = {value: 'Potato'}
      g = create :game, name: 'Potato'

      expect(Game).to receive(:exact_filter)
        .with(:name, params)
        .and_return(["name = ?", 'Potato'])

      attrs = register_and_get_filter(:wakawaka, :exact_filter, {column: :name}, params)
      expect(attrs[0]['id']).to eq g.id
    end
  end
end
