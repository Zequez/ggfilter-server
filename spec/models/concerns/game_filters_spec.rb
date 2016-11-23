describe GameFilters do
  # TODO: Convert it to a shared example...

  def create_from_steam_game(steam_game_attrs, game_attrs = {})
    sg = create :steam_game, steam_game_attrs
    sg.game
  end

  def self.gg(&block)
    define_method :get_games, &block
  end

  def self.gg_game(column_name, type, behaviour)
    gg{ |params| Game.where Game.method(type).call(exact_filter(column_name, params)) }
    it_behaves_like behaviour
  end

  def self.gg_steam_game(column_name, type, behaviour)
    gg{ |params| Game.joins(:steam_game).where Game.method(type).call("steam_games.#{column_name}", params) }
    it_behaves_like behaviour
  end

  def self.gg_filters(filters_names, behaviour)
    filters_names.each do |filter_name|
      context "##{filter_name}" do
        gg{ |params| Game.apply_filter(filter_name, params) }
        it_behaves_like behaviour
      end
    end
  end

  shared_examples '.name_filter' do
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

  describe '.name_filter directly' do
    def get_games(params); Game.where Game.name_filter(:name, params) end
    it_behaves_like '.name_filter'
  end

  describe '.name_filter in filters' do
    def get_games(params); Game.apply_filter(:name, params) end
    it_behaves_like '.name_filter'
  end

  shared_examples '.exact_filter' do
    it 'should match exact games' do
      _g1 = create_from_steam_game steam_id: 1234
      g2 = create_from_steam_game steam_id: 123
      expect(get_games({value: 123})).to match_array [g2]
    end
  end

  describe '.exact_filter directly' do
    gg_steam_game(:steam_id, :exact_filter, '.exact_filter')
  end

  describe 'filters using .exact_filter' do
    gg_filters([:steam_id], '.exact_filter')
  end

  shared_examples '.range_filter' do
    it 'should filter a column by a number range' do
      _g1 = create_from_steam_game reviews_count: 200, price: 200
      g2 = create_from_steam_game reviews_count: 340, price: 340
      g3 = create_from_steam_game reviews_count: 360, price: 360
      _g4 = create_from_steam_game reviews_count: 700, price: 700
      expect(get_games({gt: 300, lt: 600})).to match_array [g2, g3]
    end
  end

  describe '.range_filter directly' do
    gg_steam_game(:reviews_count, :range_filter, '.range_filter')
  end

  describe 'filters using .range_filter' do
    gg_filters([:steam_price, :steam_reviews_count], '.range_filter')
  end


  describe '.date_range_filter' do
    it 'should accept date-columns and filter from unix timestamps' do
      _g1 = create_from_steam_game released_at: 1.years.ago
      g2 = create_from_steam_game released_at: 3.years.ago
      g3 = create_from_steam_game released_at: 4.years.ago
      _g4 = create_from_steam_game released_at: 7.years.ago

      games = Game.joins(:steam_game).where Game.date_range_filter('steam_games.released_at', {
        gt: 5.years.ago.to_i,
        lt: 2.years.ago.to_i,
        filter: true
      })

      expect(games).to match_array [g2, g3]
    end
  end

  describe '.relative_date_range_filter' do
    it 'should accept date-columns and filter from time in seconds relative to now' do
      _g1 = create_from_steam_game released_at: 1.years.ago
      g2 = create_from_steam_game released_at: 3.years.ago
      g3 = create_from_steam_game released_at: 4.years.ago
      _g4 = create_from_steam_game released_at: 7.years.ago

      games = Game.joins(:steam_game).where Game.relative_date_range_filter(:released_at, {
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
      @games.push create_from_steam_game platforms: 0b100
      @games.push create_from_steam_game platforms: 0b010
      @games.push create_from_steam_game platforms: 0b001
      @games.push create_from_steam_game platforms: 0b110
      @games.push create_from_steam_game platforms: 0b011
      @games.push create_from_steam_game platforms: 0b101
      @games.push create_from_steam_game platforms: 0b111
    end

    it 'should filter with AND' do
      games = Game.joins(:steam_game).where Game.boolean_filter('steam_games.platforms', {
        or: false,
        value: 0b101
      })

      expect(games).to match_array([@games[5], @games[6]])
    end

    it 'should filter with OR' do
      games = Game.joins(:steam_game).where Game.boolean_filter('steam_games.platforms', {
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
