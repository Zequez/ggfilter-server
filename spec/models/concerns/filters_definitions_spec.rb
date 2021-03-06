describe FiltersDefinitions do
  def self.use_filter(name, column)
    define_method :get_games do |query|
      Game.where(Game.send(name, column, query))
    end
  end

  describe '.name_filter' do
    use_filter :name_filter, :name

    it 'should return only the games with the same name' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'
      expect(get_games({value: 'Galaxy'})).to match_array [g2]
    end

    it 'should match partial names' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'
      expect(get_games({value: 'Ga'})).to match_array [g2]
    end

    it 'should match the first part of each word' do
      create :game, name: 'Potato Galaxy'
      g2 = create :game, name: 'Scooby Doo Advanture'
      expect(get_games({value: 'Sc Doo Adv'})).to match_array [g2]
    end

    it 'should be case insensitive' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'
      expect(get_games({value: 'galaxy'})).to match_array [g2]
    end

    it 'should also find by roman numbers if given decimal numbers' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Civilization IV'
      expect(get_games({value: 'Civilization 4'})).to match_array [g2]
    end
  end

  describe '.exact_filter' do
    use_filter :exact_filter, :name

    it 'should match exact games' do
      create :game, name: '12345'
      g2 = create :game, name: '123'
      expect(get_games({value: '123'})).to match_array [g2]
    end
  end

  describe '.range_filter' do
    use_filter :range_filter, :lowest_price

    it 'should filter a column by a number range' do
      create :game, lowest_price: 200
      g2 = create :game, lowest_price: 340
      g3 = create :game, lowest_price: 360
      create :game, lowest_price: 700
      expect(get_games({gt: 300, lt: 600})).to match_array [g2, g3]
    end
  end

  describe '.date_range_filter', focus: true do
    use_filter :date_range_filter, :released_at

    before :each do
      @g1 = create :game, released_at: 1.years.ago
      @g2 = create :game, released_at: 3.years.from_now
      @g3 = create :game, released_at: Date.parse('2000-07-20')
      @g4 = create :game, released_at: Date.parse('2001-03-03')
    end

    it 'should accept absolute dates with years only' do
      expect(get_games(gte: '2000', lte: '2001'))
      .to match_array [@g3, @g4]
    end

    it 'should accept absolute dates with years and months' do
      expect(get_games(gte: '2000-08', lte: '2001'))
      .to match_array [@g4]
    end

    it 'should accept absolute dates with years, months and days' do
      expect(get_games(gte: '2000-07-19', lte: '2001-03-02'))
      .to match_array [@g3]
    end

    it 'should accept relative dates into the past in seconds' do
      expect(get_games(gte: -2.years.to_i, lte: 0))
      .to match_array [@g1]
    end

    it 'should accept relative dates into the future in seconds' do
      expect(get_games(gte: 0, lte: 5.years.to_i))
      .to match_array [@g2]
    end
  end

  describe '.boolean_filter' do
    use_filter :boolean_filter, :platforms

    before :each do
      @games = []
      @games.push create :game, platforms: 0b100
      @games.push create :game, platforms: 0b010
      @games.push create :game, platforms: 0b001
      @games.push create :game, platforms: 0b110
      @games.push create :game, platforms: 0b011
      @games.push create :game, platforms: 0b101
      @games.push create :game, platforms: 0b111
    end

    it 'should filter with AND' do
      games = get_games({value: 0b101, mode: 'and'})
      expect(games).to match_array([@games[5], @games[6]])
    end

    it 'should filter with OR' do
      games = get_games({value: 0b101, mode: 'or'})
      expect(games).to match_array([
        @games[0],
        @games[2],
        @games[3],
        @games[4],
        @games[5],
        @games[6]
      ])
    end

    it 'should filter with XOR' do
      games = get_games({value: 0b101, mode: 'xor'})
      expect(games.pluck(:platforms)).to match_array([0b100, 0b001, 0b110, 0b011])
    end

    it 'should filter with XOR when using a single value' do
      games = get_games({value: 0b100, mode: 'xor'})
      expect(games.pluck(:platforms)).to match_array([0b100])
    end
  end

  describe '.filter_by_tags' do
    use_filter :tags_filter, :tags

    before :each do
      @t1 = create :tag
      @t2 = create :tag
      @t3 = create :tag
      @g1 = create :game, tags: [@t1.id, @t3.id]
      @g2 = create :game, tags: [@t1.id, @t2.id]
      @g3 = create :game, tags: [@t2.id, @t3.id]
      @g4 = create :game, tags: [@t2.id]
      @g5 = create :game, tags: [@t2.id, @t3.id, @t1.id]
    end

    it 'should return games with the given tags ids' do
      games = get_games({ tags: [@t1.id, @t3.id] })
      expect(games).to match_array [@g1, @g5]
    end

    it 'should return games with the given tags names' do
      games = get_games({ tags: [@t1.name, @t3.name] })
      expect(games).to match_array [@g1, @g5]
    end

    it 'should reject games with the given reject names' do
      games = get_games({ tags: [@t1.name], reject: [@t3.id] })
      expect(games).to match_array [@g2]
    end

    it 'should select tags with OR instead of AND too' do
      games = get_games({ tags: [@t1.name, @t3.name], mode: 'or' })
      expect(games).to match_array [@g1, @g2, @g3, @g5]
    end

    it 'should select tags with OR instead of AND, but respect rejections always' do
      games = get_games({ tags: [@t2.name, @t3.name], reject: [@t1.name], mode: 'or' })
      expect(games).to match_array [@g3, @g4]
    end
  end
end
