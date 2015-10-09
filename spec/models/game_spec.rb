describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :name_slug }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  describe '.for_steam_game_scraping' do
    it 'should return new'
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
            game.steam_reviews_scraped_at = 31.days.ago
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
