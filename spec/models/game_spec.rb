describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :name_slug }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  describe '.filter_by_name' do
    it 'should return only the games with the same name' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'Galaxy', filter: true)
      expect(games).to match_array [g2]
    end

    it 'should be able to highlight instead of filtering' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'Galaxy', highlight: true)

      expect(games).to match_array [g1, g2]
      highlighted = games.map(&:hl_name)

      expect(highlighted).to match_array [true, false]
    end

    it 'should be able to highlight AND filter' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'Galaxy', filter: true, highlight: true)

      expect(games).to match_array [g2]
      highlighted = games.map(&:hl_name)

      expect(highlighted).to match_array [true]
    end

    it 'should match partial names' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'Ga', filter: true, highlight: true)

      expect(games).to match_array [g2]
      highlighted = games.map(&:hl_name)

      expect(highlighted).to match_array [true]
    end

    it 'should match the first part of each word' do
      create :game, name: 'Potato Galaxy'
      g2 = create :game, name: 'Scooby Doo Advanture'

      games = Game.filter_by_name(value: 'Sc Doo Adv', filter: true)

      expect(games).to match_array [g2]
    end

    it 'should be case insensitive' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'galaxy', filter: true)
      expect(games).to match_array [g2]
    end

    it 'should also find by roman numbers if given decimal numbers' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Civilization IV'

      games = Game.filter_by_name(value: 'Civilization 4', filter: true)
      expect(games).to match_array [g2]
    end
  end

  describe '.sort_by_name' do
    it 'should sort alphanumerically ascending by name' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Arguments'
      g3 = create :game, name: 'Aáron'
      g4 = create :game, name: 'booo'

      games = Game.sort_by_name(:asc)
      expect(games).to eq [g3, g2, g4, g1]
    end

    it 'should sort descending by name' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Arguments'
      g3 = create :game, name: 'Aáron'
      g4 = create :game, name: 'booo'

      games = Game.sort_by_name(:desc)
      expect(games).to eq [g1, g4, g2, g3]
    end
  end
end
