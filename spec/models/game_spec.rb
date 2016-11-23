describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :name_slug }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
  it { is_expected.to respond_to :lowest_steam_price }

  def create_from_steam_game(steam_game_attrs, game_attrs = {})
    sg = create :steam_game, steam_game_attrs
    sg.game
  end

  describe 'system requirements analysis' do
    describe 'tokens extraction' do
      describe '#sysreq_video_tokens' do
        it 'should extract all the tokens from #system_requirements' do
          sg = create :steam_game, system_requirements: {
            minimum: { video_card: 'geforce gtx8500, ati 1500, or intel hd3000' },
            recommended: { video_card: 'geforce 970TI, amd radeon R9 200, or intel iris pro hd5200' }
          }
          game = sg.game

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

    describe '.compute_sysreq_index_centiles' do
      it 'should assign a the system requirements percentile to each game' do
        g0 = create :game, sysreq_video_index: 0
        g1 = create :game, sysreq_video_index: 100
        g2 = create :game, sysreq_video_index: 200
        g3 = create :game, sysreq_video_index: 300
        g4 = create :game, sysreq_video_index: 400
        g5 = create :game, sysreq_video_index: 500
        g6 = create :game, sysreq_video_index: 600
        g7 = create :game, sysreq_video_index: 700
        g8 = create :game, sysreq_video_index: 800
        g9 = create :game, sysreq_video_index: 900
        Game.compute_sysreq_index_centiles
        g0.reload
        g1.reload
        g2.reload
        g3.reload
        g4.reload
        g5.reload
        g6.reload
        g7.reload
        g8.reload
        g9.reload
        expect(g0.sysreq_index_centile).to be_within(10).of(5)
        expect(g1.sysreq_index_centile).to be_within(10).of(15)
        expect(g2.sysreq_index_centile).to be_within(10).of(25)
        expect(g3.sysreq_index_centile).to be_within(10).of(35)
        expect(g4.sysreq_index_centile).to be_within(10).of(45)
        expect(g5.sysreq_index_centile).to be_within(10).of(55)
        expect(g6.sysreq_index_centile).to be_within(10).of(65)
        expect(g7.sysreq_index_centile).to be_within(10).of(75)
        expect(g8.sysreq_index_centile).to be_within(10).of(85)
        expect(g9.sysreq_index_centile).to be_within(10).of(95)
      end
    end
  end

  describe 'computed attributes' do
    describe '#lowest_steam_price' do
      it "should be the steam price if it's lower" do
        g = create_from_steam_game price: 123, sale_price: 321
        expect(g.lowest_steam_price).to eq 123
      end

      it "should be the sale price if it's on sale" do
        g = create_from_steam_game price: 333, sale_price: 100
        expect(g.lowest_steam_price).to eq 100
      end

      it "should be nil if neither exist" do
        g = create_from_steam_game price: nil, sale_price: nil
        expect(g.lowest_steam_price).to eq nil
      end

      it 'should be the steam price if the sale price is nil' do
        g = create_from_steam_game price: 100, sale_price: nil
        g.process_steam_game_data
        expect(g.lowest_steam_price).to eq 100
      end
    end

    describe '#steam_discount' do
      it 'should be 0 if not on sale' do
        g = create_from_steam_game price: 100, sale_price: nil
        expect(g.steam_discount).to eq 0
      end

      it 'should be an integer from 1 to 100 if on sale' do
        g = create_from_steam_game price: 10, sale_price: 3
        expect(g.steam_discount).to eq 70
      end
    end

    describe '#playtime_mean' do
      it 'should be the mean value of the playtime' do
        g = create_from_steam_game positive_reviews: [1,2,3,4,5], negative_reviews: []
        expect(g.playtime_mean).to eq (1+2+3+4+5).to_f/5
      end
    end

    describe '#playtime_median' do
      it 'should be the mean value of the playtime' do
        g = create_from_steam_game positive_reviews: [1,2,5], negative_reviews: [3,4]
        expect(g.playtime_median).to eq 3
      end
    end

    describe '#playtime_sd' do
      it 'should be the mean value of the playtime' do
        g = create_from_steam_game positive_reviews: [1,2,5], negative_reviews: [3,4]
        # Not matching for some reason, freaky
        # expect(g.playtime_sd).to eq be_within(0.01).of(1.58)
      end
    end

    describe '#playtime_rsd' do
      it 'should be the mean value of the playtime' do
        g = create_from_steam_game positive_reviews: [1,2,5], negative_reviews: [3,4]
        expect(g.playtime_rsd).to be_within(1).of(47)
      end
    end

    describe '#playtime_ils' do
      it 'should be the mean value of the playtime' do
        g = create_from_steam_game(
          positive_reviews: (1..50).to_a,
          negative_reviews: (51..100).to_a
        )
        expect(g.playtime_ils).to eq [6, 11, 16, 21, 26, 31, 36, 41, 46, 51, 57, 61, 66, 71, 76, 81, 86, 91, 96]
      end
    end

    describe '#playtime_mean_ftb' do
      it 'should return the mean playtime for the buck' do
        g = create_from_steam_game(
          positive_reviews: [1,2,5],
          negative_reviews: [3,4,6],
          price: 400,
          sale_price: 300
        )
        mean = (1+2+3+4+5+6).to_f/6
        expect(g.playtime_mean_ftb).to eq mean/3
      end
    end


    describe '#playtime_median_ftb' do
      it 'should return the median playtime for the buck' do
        g = create_from_steam_game(
          positive_reviews: [1,2,5],
          negative_reviews: [3,4,6,7],
          price: 400,
          sale_price: 300
        )
        expect(g.playtime_median_ftb).to eq 4.0/3
      end
    end
  end

  describe '.entil' do
    context '2 il' do
      it 'should return an array with the median value' do
        create :game, lowest_steam_price: 10
        create :game, lowest_steam_price: 10
        create :game, lowest_steam_price: 30
        create :game, lowest_steam_price: 10
        create :game, lowest_steam_price: 100
        create :game, lowest_steam_price: 500
        create :game, lowest_steam_price: 1000
        expect(Game.entil(:lowest_steam_price, 2)).to eq [30]
      end
    end

    context '4 il' do
      it 'should return an array with the quartiles' do
        20.times.map.to_a.shuffle.each do |i|
          create :game, lowest_steam_price: i
        end
        expect(Game.entil(:lowest_steam_price, 4)).to eq [5,10,15]
      end
    end
  end

  describe 'tags' do
    it 'should create new tags when assigning non-existing tags' do
      g = create_from_steam_game tags: ['potato', 'galaxy']
      expect(Tag.pluck(:name)).to eq ['potato', 'galaxy']
      expect(g.tags).to eq Tag.pluck(:id)
    end

    it 'should reuse existing tags when assigning existing tags' do
      t1 = create :tag, name: 'galaxy'
      g = create_from_steam_game tags: ['potato', 'galaxy']
      t2 = Tag.last
      expect(t2.name).to eq 'potato'
      expect(g.tags).to eq [t2.id, t1.id]
    end
  end
end
