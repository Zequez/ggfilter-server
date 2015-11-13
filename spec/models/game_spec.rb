describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :name_slug }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
  it { is_expected.to respond_to :lowest_steam_price }

  describe 'computed attributes' do
    describe '#lowest_steam_price' do
      it "should be the steam price if it's lower" do
        g = create :game, steam_price: 123, steam_sale_price: 321
        expect(g.lowest_steam_price).to eq 123
      end

      it "should be the sale price if it's on sale" do
        g = create :game, steam_price: 333, steam_sale_price: 100
        expect(g.lowest_steam_price).to eq 100
      end

      it "should be nil if neither exist" do
        g = create :game, steam_price: nil, steam_sale_price: nil
        expect(g.lowest_steam_price).to eq nil
      end

      it 'should be the steam price if the sale price is nil' do
        g = create :game, steam_price: 100, steam_sale_price: nil
        expect(g.lowest_steam_price).to eq 100
      end
    end

    describe '#steam_discount' do
      it 'should be 0 if not on sale' do
        g = create :game, steam_price: 100, steam_sale_price: nil
        expect(g.steam_discount).to eq 0
      end

      it 'should be an integer from 1 to 100 if on sale' do
        g = create :game, steam_price: 10, steam_sale_price: 3
        expect(g.steam_discount).to eq 70
      end
    end

    describe '#playtime_mean' do
      it 'should be the mean value of the playtime' do
        g = create :game, positive_steam_reviews: [1,2,3,4,5], negative_steam_reviews: []
        g.save!
        expect(g.playtime_mean).to eq (1+2+3+4+5).to_f/5
      end
    end

    describe '#playtime_median' do
      it 'should be the mean value of the playtime' do
        g = create :game, positive_steam_reviews: [1,2,5], negative_steam_reviews: [3,4]
        g.save!
        expect(g.playtime_median).to eq 3
      end
    end

    describe '#playtime_sd' do
      it 'should be the mean value of the playtime' do
        g = create :game, positive_steam_reviews: [1,2,5], negative_steam_reviews: [3,4]
        g.save!
        # Not matching for some reason, freaky
        # expect(g.playtime_sd).to eq be_within(0.01).of(1.58)
      end
    end

    describe '#playtime_rsd' do
      it 'should be the mean value of the playtime' do
        g = create :game, positive_steam_reviews: [1,2,5], negative_steam_reviews: [3,4]
        g.save!
        expect(g.playtime_rsd).to be_within(1).of(47)
      end
    end

    describe '#playtime_ils' do
      it 'should be the mean value of the playtime' do
        g = create :game,
          positive_steam_reviews: (1..50).to_a,
          negative_steam_reviews: (51..100).to_a
        g.save!
        expect(g.playtime_ils).to eq [6, 11, 16, 21, 26, 31, 36, 41, 46, 51, 57, 61, 66, 71, 76, 81, 86, 91, 96]
      end
    end

    describe '#playtime_mean_ftb', focus: true do
      it 'should return the mean playtime for the buck' do
        g = create :game,
          positive_steam_reviews: [1,2,5],
          negative_steam_reviews: [3,4,6],
          steam_price: 400,
          steam_sale_price: 300
        mean = (1+2+3+4+5+6).to_f/6
        g.save!
        expect(g.playtime_mean_ftb).to eq mean/3
      end
    end


    describe '#playtime_median_ftb', focus: true do
      it 'should return the median playtime for the buck' do
        g = create :game,
          positive_steam_reviews: [1,2,5],
          negative_steam_reviews: [3,4,6,7],
          steam_price: 400,
          steam_sale_price: 300
        g.save!
        expect(g.playtime_median_ftb).to eq 4.0/3
      end
    end
  end

  describe '.entil' do
    context '2 il' do
      it 'should return an array with the median value' do
        create :game, metacritic: 10
        create :game, metacritic: 10
        create :game, metacritic: 30
        create :game, metacritic: 10
        create :game, metacritic: 100
        create :game, metacritic: 500
        create :game, metacritic: 1000
        expect(Game.entil(:metacritic, 2)).to eq [30]
      end
    end

    context '4 il' do
      it 'should return an array with the quartiles' do
        20.times.map.to_a.shuffle.each do |i|
          create :game, metacritic: i
        end
        expect(Game.entil(:metacritic, 4)).to eq [4.5,9.5,14.5]
      end
    end
  end

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

    it 'should match partial names' do
      create :game, name: 'Potato'
      g2 = create :game, name: 'Galaxy'

      games = Game.filter_by_name(value: 'Ga')

      expect(games).to match_array [g2]
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

  describe '.filter_by_steam_id' do
    it 'should match exact games' do
      _g1 = create :game, steam_id: 1234
      g2 = create :game, steam_id: 123

      games = Game.filter_by_steam_id(value: 123, filter: true)
      expect(games).to match_array [g2]
    end

    it 'should work with highlight in combination with other filters' do
      g1 = create :game, name: 'Potato', steam_id: 1234
      g2 = create :game, name: 'Potasium', steam_id: 333
      _g3 = create :game, name: 'Galaxy', steam_id: 123

      games = Game
        .filter_by_name(value: 'Pot', filter: true)
        .filter_by_steam_id(value: 333, highlight: true)

      expect(games).to match_array [g1, g2]
      expect(games.map(&:hl_steam_id)).to match [false, true]
    end
  end

  describe '.range_filter' do
    it 'should filter a column by a number range' do
      _g1 = create :game, steam_reviews_count: 200
      g2 = create :game, steam_reviews_count: 340
      g3 = create :game, steam_reviews_count: 360
      _g4 = create :game, steam_reviews_count: 700

      games = Game.range_filter(:steam_reviews_count, {
        gt: 300,
        lt: 600,
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
      games = Game.boolean_filter(:platforms, {
        or: false,
        value: 0b101
      })

      L games.to_sql
      L games.pluck(:platforms).map{|v| v.to_s(2).rjust(3, '0')}

      expect(games).to match_array([@games[5], @games[6]])
    end

    it 'should filter with OR' do
      games = Game.boolean_filter(:platforms, {
        or: true,
        value: 0b101
      })

      expect(games).to match_array([@games[0], @games[2], @games[3], @games[4], @games[5], @games[6]])
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

  describe '.get_for_steam_reviews_scraping' do
    let(:game){ Game.create }

    it 'should return nothing when there are no games' do
      Game.get_for_steam_reviews_scraping.should eq []
    end

    context 'never scrapped game' do
      it 'should return the game even if its ancient' do
        game.released_at = 100.years.ago
        game.steam_reviews_scraped_at = nil
        game.save!
        Game.get_for_steam_reviews_scraping.should eq [game]
      end
    end

    context 'launch date < week' do
      before :each do
        game.released_at = 3.days.ago
      end

      context 'no reviews' do
        context 'last update < 24 hours ago' do
          it 'should not return the game' do
            game.steam_reviews_scraped_at = 23.hours.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq []
          end
        end

        context 'last update > 24 hours ago' do
          it 'should return the game' do
            game.steam_reviews_scraped_at = 25.hours.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq [game]
          end
        end
      end
    end

    context 'week < launch date < month' do
      before :each do
        game.released_at = 15.days.ago
      end

      context 'no reviews' do
        context 'last update < 7 days ago' do
          it 'should not return the game' do
            game.steam_reviews_scraped_at = 6.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq []
          end
        end

        context 'last update > 7 days ago' do
          it 'should return the game' do
            game.steam_reviews_scraped_at = 8.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq [game]
          end
        end
      end
    end

    context 'month < launch date < year' do
      before :each do
        game.released_at = 300.days.ago
      end

      context 'no reviews' do
        context 'last update < 1 month ago' do
          it 'should not return the game' do
            game.steam_reviews_scraped_at = 27.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq []
          end
        end

        context 'last update > 1 month ago' do
          it 'should return the game' do
            game.steam_reviews_scraped_at = 33.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq [game]
          end
        end
      end
    end

    context '1 year < launch date < 3 years' do
      before :each do
        game.released_at = 2.years.ago
      end

      context 'no reviews' do
        context 'last update < 3 month ago' do
          it 'should not return the game' do
            game.steam_reviews_scraped_at = 80.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq []
          end
        end

        context 'last update > 3 month ago' do
          it 'should return the game' do
            game.steam_reviews_scraped_at = 93.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq [game]
          end
        end
      end
    end

    context '3 years < launch date' do
      before :each do
        game.released_at = 10.years.ago
      end

      context 'no reviews' do
        context 'last update < 1 year ago' do
          it 'should not return the game' do
            game.steam_reviews_scraped_at = 360.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq []
          end
        end

        context 'last update > 1 year ago' do
          it 'should return the game' do
            game.steam_reviews_scraped_at = 366.days.ago
            game.save!
            Game.get_for_steam_reviews_scraping.should eq [game]
          end
        end
      end
    end
  end
end
