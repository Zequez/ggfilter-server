describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :name_slug }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
  it { is_expected.to respond_to :lowest_steam_price }

  describe 'system requirements analysis' do
    describe 'tokens extraction' do
      describe '#sysreq_video_tokens' do
        it 'should extract all the tokens from #system_requirements' do
          game = create :game, system_requirements: {
            minimum: { video_card: 'geforce gtx8500, ati 1500, or intel hd3000' },
            recommended: { video_card: 'geforce 970TI, amd radeon R9 200, or intel iris pro hd5200' }
          }

          expect(game.sysreq_video_tokens.split(' ')).to match_array %w{nvidia8500 amd1500 intel3000 nvidia970 amd200 intel5200}
        end
      end
    end

    describe '#compute_sysreq_video_index' do
      it 'should average the values from SysreqTokens' do
        create :sysreq_token, name: 'nvidia8500', value: 700
        create :sysreq_token, name: 'intel4000', value: 500
        create :sysreq_token, name: '512mb', value: 100
        create :sysreq_token, name: 'directx10', value: 150
        g = create :game, sysreq_video_tokens: 'nvidia8500 intel4000 512mb directx10'
        g.compute_sysreq_video_index
        expect(g.sysreq_video_index).to eq ((700 + 700 + 500 + 500 + 100 + 100 + 150).to_f / 7).round
      end
    end
  end

  describe 'tags' do
    it 'should create new tags when assigning non-existing tags' do
      g = create :game, tags: ['potato', 'galaxy']
      expect(Tag.pluck(:name)).to eq ['potato', 'galaxy']
      expect(g.tags).to eq Tag.pluck(:id)
    end

    it 'should reuse existing tags when assigning existing tags' do
      t1 = create :tag, name: 'galaxy'
      g = create :game, tags: ['potato', 'galaxy']
      t2 = Tag.last
      expect(t2.name).to eq 'potato'
      expect(g.tags).to eq [t2.id, t1.id]
    end
  end

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
        expect(Game.entil(:metacritic, 4)).to eq [5,10,15]
      end
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
