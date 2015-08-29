describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  describe '#filter_by_name' do
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

      expect(highlighted).to match_array [1, 0]
    end

    it 'should be able to highlight AND filter' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'Galaxy', filter: true, highlight: true)

      expect(games).to match_array [g2]
      highlighted = games.map(&:hl_name)

      expect(highlighted).to match_array [1]
    end

    it 'should match partial names' do

    end

    it 'should be case insensitive' do
      create :game, name: 'Potato'
      g = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'galaxy', filter: true)
      expect(games).to match_array [g]
    end

    it 'should return the best matches on top' do

    end
  end
end
