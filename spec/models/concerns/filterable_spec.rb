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

    it 'should allow you to register a filter with a different column name' do
      params = {value: 'Potato'}
      create :game, name: 'Potato'

      expect(Game).to receive(:exact_filter)
        .with(:name, params)
        .and_return(["name = ?", 'Potato'])

      attrs = register_and_get_filter(:wakawaka, :exact_filter, {column: :name}, params)
      expect(attrs[0]['name']).to eq 'Potato'
    end

    it 'should allow you to register a filter with a column of a different table' do
      steam_game = create :steam_game, steam_id: 1234
      create :game, name: 'Potato', steam_game: steam_game
      attrs = register_and_get_filter(:wololo, :exact_filter,
        {joins: :steam_game, column: [:steam_game, :steam_id]},
        {value: 1234}
      )
      expect(attrs[0]['wololo']).to eq 1234
    end

    it 'should allow you to rename the column returned' do
      steam_game = create :steam_game, steam_id: 1234
      create :game, name: steam_game.name, steam_game: steam_game
      attrs = register_and_get_filter(:wololo, :exact_filter,
        {joins: :steam_game, column: [:steam_game, :steam_id], as: :steam_id_bitch},
        {value: 1234}
      )
      expect(attrs[0]['steam_id']).to eq nil
      expect(attrs[0]['steam_id_bitch']).to eq 1234
    end

    it 'should allow you to select multiple columns' do
      steam_game = create :steam_game, steam_id: 1234, positive_reviews_count: 321
      create :game, steam_game: steam_game
      attrs = register_and_get_filter(:wololo, :exact_filter,
        {
          joins: :steam_game,
          column: [:steam_game, :steam_id],
          select: ['steam_games.steam_id as potato', 'steam_games.positive_reviews_count as galaxy']
        },
        {value: 1234}
      )
      expect(attrs[0]['potato']).to eq 1234
      expect(attrs[0]['galaxy']).to eq 321
    end

    it 'should add the AS column to the selectors even if there is already a select' do
      steam_game = create :steam_game, steam_id: 1234, positive_reviews_count: 321
      create :game, steam_game: steam_game
      attrs = register_and_get_filter(:wololo, :exact_filter,
        {
          joins: :steam_game,
          column: [:steam_game, :steam_id],
          as: 'potato',
          select: ['steam_games.positive_reviews_count as galaxy']
        },
        {value: 1234}
      )
      expect(attrs[0]['potato']).to eq 1234
      expect(attrs[0]['galaxy']).to eq 321
    end

    it 'should allow you to provide the column with an association and join it automatically' do
      steam_game = create :steam_game, steam_id: 1234
      create :game, steam_game: steam_game
      attrs = register_and_get_filter(:wololo, :exact_filter,
        {
          column: [:steam_game, :steam_id]
        },
        {value: 1234}
      )
      expect(attrs[0]['wololo']).to eq 1234
    end
  end
end
