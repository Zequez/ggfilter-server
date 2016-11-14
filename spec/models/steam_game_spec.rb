describe SteamGame, type: :model do
  it 'should create a new Game with the same name after being created' do
    create :steam_game, name: 'Potato Salad'
    expect(Game.first.name).to eq('Potato Salad')
  end

  it 'should associate itself with a game if it already exist' do
    g = create :game, name: 'Galaxy Simulator'
    sg = create :steam_game, name: 'Galaxy Simulator'
    expect(Game.count).to eq(1)
    g.reload
    expect(g.steam_game).to eq sg
  end

  it 'should make the Game loaded in the SteamGame' do
    sg = create :steam_game, name: 'Potato Salad'
    expect(sg.game).to_not be_nil
  end

  describe '.get_for_reviews_scraping' do
    let(:game){ create :steam_game }

    it 'should return nothing when there are no games' do
      SteamGame.get_for_reviews_scraping.should eq []
    end

    context 'never scrapped game' do
      it 'should return the game even if its ancient' do
        game.released_at = 100.years.ago
        game.reviews_scraped_at = nil
        game.save!
        SteamGame.get_for_reviews_scraping.should eq [game]
      end
    end

    context 'launch date < week' do
      before :each do
        game.released_at = 3.days.ago
      end

      context 'no reviews' do
        context 'last update < 24 hours ago' do
          it 'should not return the game' do
            game.reviews_scraped_at = 23.hours.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq []
          end
        end

        context 'last update > 24 hours ago' do
          it 'should return the game' do
            game.reviews_scraped_at = 25.hours.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq [game]
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
            game.reviews_scraped_at = 6.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq []
          end
        end

        context 'last update > 7 days ago' do
          it 'should return the game' do
            game.reviews_scraped_at = 8.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq [game]
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
            game.reviews_scraped_at = 27.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq []
          end
        end

        context 'last update > 1 month ago' do
          it 'should return the game' do
            game.reviews_scraped_at = 33.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq [game]
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
            game.reviews_scraped_at = 80.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq []
          end
        end

        context 'last update > 3 month ago' do
          it 'should return the game' do
            game.reviews_scraped_at = 93.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq [game]
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
            game.reviews_scraped_at = 360.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq []
          end
        end

        context 'last update > 1 year ago' do
          it 'should return the game' do
            game.reviews_scraped_at = 367.days.ago
            game.save!
            SteamGame.get_for_reviews_scraping.should eq [game]
          end
        end
      end
    end
  end
end
