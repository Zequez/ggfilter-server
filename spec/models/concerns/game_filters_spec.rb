describe GameFilters do
  # TODO: Convert it to a shared example...

  describe '.name_filter' do
    it 'should return only the games with the same name' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.where Game.name_filter(:name, {value: 'Galaxy', filter: true})
      expect(games).to match_array [g2]
    end

    it 'should match partial names' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.where Game.name_filter(:name, {value: 'Ga'})
      expect(games).to match_array [g2]
    end

    it 'should match the first part of each word' do
      create :game, name: 'Potato Galaxy'
      g2 = create :game, name: 'Scooby Doo Advanture'

      games = Game.where Game.name_filter(:name, {value: 'Sc Doo Adv'})
      expect(games).to match_array [g2]
    end

    it 'should be case insensitive' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.where Game.name_filter(:name, {value: 'galaxy'})
      expect(games).to match_array [g2]
    end

    it 'should also find by roman numbers if given decimal numbers' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Civilization IV'

      games = Game.where Game.name_filter(:name, {value: 'Civilization 4'})
      expect(games).to match_array [g2]
    end
  end

  describe '.filter_by_steam_id' do
    it 'should match exact games' do
      _g1 = create :game, steam_id: 1234
      g2 = create :game, steam_id: 123

      games = Game.where Game.exact_filter(:steam_id, {value: 123})
      expect(games).to match_array [g2]
    end
  end

  describe '.range_filter' do
    it 'should filter a column by a number range' do
      _g1 = create :game, steam_reviews_count: 200
      g2 = create :game, steam_reviews_count: 340
      g3 = create :game, steam_reviews_count: 360
      _g4 = create :game, steam_reviews_count: 700

      games = Game.where Game.range_filter(:steam_reviews_count, {
        gt: 300,
        lt: 600,
        filter: true
      })

      expect(games).to match_array [g2, g3]
    end

    it 'should accept date-columns and filter from unix timestamps' do
      _g1 = create :game, released_at: 1.years.ago
      g2 = create :game, released_at: 3.years.ago
      g3 = create :game, released_at: 4.years.ago
      _g4 = create :game, released_at: 7.years.ago

      games = Game.where Game.range_filter(:released_at, {
        gt: 5.years.ago.to_i,
        lt: 2.years.ago.to_i,
        filter: true
      })

      expect(games).to match_array [g2, g3]
    end
  end

  describe '.relative_date_range_filter' do
    it 'should accept date-columns and filter from time in seconds relative to now' do
      _g1 = create :game, released_at: 1.years.ago
      g2 = create :game, released_at: 3.years.ago
      g3 = create :game, released_at: 4.years.ago
      _g4 = create :game, released_at: 7.years.ago

      games = Game.where Game.relative_date_filter(:released_at, {
        gt: 5.years.to_i,
        lt: 2.years.to_i,
        filter: true
      })

      expect(games).to match_array [g2, g3]
    end
  end

  describe '.boolean_filter' do
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
      games = Game.where Game.boolean_filter(:platforms, {
        or: false,
        value: 0b101
      })

      expect(games).to match_array([@games[5], @games[6]])
    end

    it 'should filter with OR' do
      games = Game.where Game.boolean_filter(:platforms, {
        or: true,
        value: 0b101
      })

      expect(games).to match_array([@games[0], @games[2], @games[3], @games[4], @games[5], @games[6]])
    end
  end

  describe '.filter_by_tags' do
    it 'should return games with the given tags ids' do
      t1 = create :tag
      t2 = create :tag
      t3 = create :tag
      g1 = create :game, tags: [t1.id, t3.id]
      _g2 = create :game, tags: [t1.id, t2.id]
      _g3 = create :game, tags: [t2.id, t3.id]
      _g4 = create :game, tags: [t2.id]
      g5 = create :game, tags: [t2.id, t3.id, t1.id]

      games = Game.where Game.tags_filter(:tags, { tags: [t1.id, t3.id] })
      expect(games).to match_array [g1, g5]
    end
  end
end
