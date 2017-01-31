describe Game, type: :model do
  subject{ build :game }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :name_slug }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  def build_multigame(data = {})
    game = build :game

    if data[:oculus]
      game.oculus_game = create :oculus_game, data[:oculus]
    end

    if data[:steam]
      game.steam_game = create :steam_game, data[:steam]
    end

    game
  end

  describe '.find_or_build_from_name' do
    context 'game with the same slug exists' do
      it 'should returns an existing game' do
        game = create :game, name: 'Potato'
        found_game = Game.find_or_build_from_name('POTATO')
        expect(found_game).to eq game
        expect(found_game.name).to eq 'Potato'
      end
    end

    context 'game does not exist with that slugged name' do
      it 'returns a new game with the name prefilled' do
        found_game = Game.find_or_build_from_name('POTATO')
        expect(found_game.new_record?).to eq true
        expect(found_game.name).to eq 'POTATO'
      end
    end
  end

  describe '#compute_all' do
    it 'should call all the compute methods' do
      game = create :game
      expect(game).to receive :compute_stores
      expect(game).to receive :compute_prices
      expect(game).to receive :compute_ratings
      expect(game).to receive :compute_released_at

      expect(game).to receive :compute_platforms
      expect(game).to receive :compute_controllers
      expect(game).to receive :compute_vr_platforms
      expect(game).to receive :compute_vr_modes
      expect(game).to receive :compute_players

      expect(game).to receive :compute_vr_only
      expect(game).to receive :compute_playtime_stats
      expect(game).to receive :compute_tags
      expect(game).to receive :compute_sysreq_string
      expect(game).to receive :compute_sysreq_tokens

      expect(game).to receive :compute_thumbnail
      expect(game).to receive :compute_videos
      expect(game).to receive :compute_images

      game.compute_all
    end
  end

  describe '#compute_store_availability' do
    it 'sets the Steam store' do
      game = build_multigame steam: {}
      game.compute_stores
      expect(game.stores).to match_array [:steam]
    end

    it 'sets the Oculus store' do
      game = build_multigame oculus: {}
      game.compute_stores
      expect(game.stores).to match_array [:oculus]
    end

    it 'sets both stores' do
      game = build_multigame steam: {}, oculus: {}
      game.compute_stores
      expect(game.stores).to match_array [:steam, :oculus]
    end
  end

  describe '#compute_prices' do
    context 'Oculus game only' do
      it 'sets #oculus_price #oculus_price_regular #oculus_price_discount' do
        oculus_game = create :oculus_game, price: 999, price_regular: 1999
        game = build :game, oculus_game: oculus_game
        game.compute_prices
        expect(game.oculus_price).to eq 999
        expect(game.oculus_price_regular).to eq 1999
        expect(game.oculus_price_discount).to eq 50

        expect(game.lowest_price).to eq 999
        expect(game.best_discount).to eq 50
        expect(game.prices).to eq({
          'oculus' => {
            'current' => 999,
            'regular' => 1999
          }
        })
      end
    end

    context 'Steam game only' do
      it 'sets #steam_price #steam_price_regular #steam_price_discount' do
        steam_game = create :steam_game, price: 1999, sale_price: 999
        game = build :game, steam_game: steam_game
        game.compute_prices
        expect(game.steam_price).to eq 999
        expect(game.steam_price_regular).to eq 1999
        expect(game.steam_price_discount).to eq 50

        expect(game.lowest_price).to eq 999
        expect(game.best_discount).to eq 50
        expect(game.prices).to eq({
          'steam' => {
            'current' => 999,
            'regular' => 1999
          }
        })
      end
    end

    context 'Steam and Oculus games' do
      it 'sets all the prices and the correct #lowest_price' do
        steam_game = create :steam_game, price: 1999, sale_price: 999
        oculus_game = create :oculus_game, price_regular: 1999, price: 499
        game = build :game, steam_game: steam_game, oculus_game: oculus_game
        game.compute_prices

        expect(game.lowest_price).to eq 499
        expect(game.best_discount).to eq 75
        expect(game.prices).to eq({
          'steam' => {
            'current' => 999,
            'regular' => 1999
          },
          'oculus' => {
            'current' => 499,
            'regular' => 1999
          }
        })
      end
    end
  end

  describe '#compute_ratings' do
    context 'Oculus game only' do
      it 'sets #ratings_count to the Oculus game ratings' do
        oculus_game = create :oculus_game,
          rating_1: 4,
          rating_2: 2,
          rating_3: 3,
          rating_4: 4,
          rating_5: 20
        game = build :game, oculus_game: oculus_game
        game.compute_ratings

        total = (4+2+3+4+20)
        ratio = (
          (4*1 + 2*2 + 3*3 + 4*4 + 5*20).to_f / total
        ).to_f / 5
        positive = (total * ratio).floor
        negative = total - positive

        expect(game.positive_ratings_count).to eq positive
        expect(game.negative_ratings_count).to eq negative
        expect(game.ratings_ratio).to eq(
          (positive.to_f / (positive + negative) * 100).round
        )
      end

      it 'should not be an issue with no ratings' do
        oculus_game = create :oculus_game,
          rating_1: 0,
          rating_2: 0,
          rating_3: 0,
          rating_4: 0,
          rating_5: 0
        game = build :game, oculus_game: oculus_game
        game.compute_ratings

        expect(game.positive_ratings_count).to eq 0
        expect(game.negative_ratings_count).to eq 0
        expect(game.ratings_ratio).to eq nil
      end
    end

    context 'Steam game only' do
      it 'sets #ratings_count to the Steam game ratings' do
        steam_game = create :steam_game,
          positive_reviews_count: 99,
          negative_reviews_count: 10
        game = build :game, steam_game: steam_game
        game.compute_ratings

        expect(game.positive_ratings_count).to eq 99
        expect(game.negative_ratings_count).to eq 10

        expect(game.ratings_ratio).to eq (99.to_f / (10 + 99) * 100).round
      end
    end

    context 'Steam and Oculus games' do
      it 'sums both ratings' do
        oculus_game = create :oculus_game,
          rating_1: 4,
          rating_2: 2,
          rating_3: 3,
          rating_4: 4,
          rating_5: 20

        total = (4+2+3+4+20)
        ratio = (
          (4*1 + 2*2 + 3*3 + 4*4 + 5*20).to_f / total
        ).to_f / 5
        positive = (total * ratio).floor
        negative = total - positive

        steam_game = create :steam_game,
          positive_reviews_count: 99,
          negative_reviews_count: 10

        game = build :game, oculus_game: oculus_game, steam_game: steam_game
        game.compute_ratings

        expect(game.positive_ratings_count).to eq(99 + positive)
        expect(game.negative_ratings_count).to eq(10 + negative)
        expect(game.ratings_ratio).to eq(
          ((99 + positive).to_f / (99 + positive + 10 + negative) * 100).round
        )
      end
    end
  end

  describe '#compute_released_at' do
    it 'should get the date from either Steam or Oculus (prioritise Steam)' do
      oculus_game = create :oculus_game, released_at: 6.months.ago
      steam_game = create :steam_game, released_at: 4.months.ago

      game = build :game, oculus_game: oculus_game
      game.compute_released_at
      expect(game.released_at).to eq oculus_game.released_at

      game = build :game, steam_game: steam_game
      game.compute_released_at
      expect(game.released_at).to eq steam_game.released_at

      game = build :game, steam_game: steam_game, oculus_game: oculus_game
      game.compute_released_at
      expect(game.released_at).to eq steam_game.released_at
    end
  end

  describe 'flags computation' do
    describe '#compute_platforms' do
      it 'should be set to Windows if available on the Oculus store' do
        oculus_game = create :oculus_game
        game = create :game, oculus_game: oculus_game
        game.compute_platforms

        expect(game.platforms).to eq [:win]
      end

      it 'should use the Steam game data' do
        game = build_multigame oculus: {}, steam: { platforms: [:linux] }
        game.compute_platforms
        expect(game.platforms).to match_array [:win, :linux]
      end
    end

    describe '#compute_controllers' do
      it 'from Oculus should read touch and gamepad, ignore the rest' do
        game = build_multigame oculus: {
          vr_controllers: ['OCULUS_TOUCH', 'GAMEPAD', 'HYDRA', 'RACING_WHEEL']
        }
        game.compute_controllers
        expect(game.controllers).to match_array [:tracked, :gamepad]
      end

      it 'from Steam should read everything' do
        game = build_multigame oculus: {
          vr_controllers: ['OCULUS_TOUCH']
        }, steam: {
          vr_controllers: [:gamepad]
        }
        game.compute_controllers
        expect(game.controllers).to match_array [:tracked, :gamepad, :keyboard_mouse]
      end

      it 'should always add the keyboard and mouse if the game is not VR' do
        game = build_multigame steam: {
          vr_platforms: [],
          vr_controllers: [],
          controller_support: :no
        }
        game.compute_controllers
        expect(game.controllers).to match_array [:keyboard_mouse]
      end

      it 'should not add keyboad and mouse if the app is VR and it doesnt say so' do
        game = build_multigame steam: {
          vr_platforms: [:vive],
          vr_controllers: [:gamepad, :tracked],
          controller_support: :no
        }
        game.compute_controllers
        expect(game.controllers).to match_array [:gamepad, :tracked]
      end

      it 'should set controller support same as Steam' do
        game = build_multigame steam: {
          controller_support: :partial
        }
        game.compute_controllers
        expect(game.gamepad).to eq :partial
      end

      it 'should set controller support from Oculus' do
        game = build_multigame oculus: {
          vr_controllers: ['GAMEPAD']
        }
        game.compute_controllers
        expect(game.gamepad).to eq :full
      end

      it 'should prioritise the Steam information on controller support' do
        game = build_multigame steam: {
          controller_support: :partial
        }, oculus: {
          vr_controllers: ['GAMEPAD']
        }
        game.compute_controllers
        expect(game.gamepad).to eq :partial
      end

      it 'should set the gamepad to :no if not available on Steam or Oculus' do
        game = build_multigame oculus: {
          vr_controllers: ['OCULUS_TOUCH']
        }
        game.compute_controllers
        expect(game.gamepad).to eq :no
      end
    end

    describe '#compute_vr_platforms' do
      it 'should read them from Steam' do
        game = build_multigame steam: {
          vr_platforms: [:vive, :rift, :osvr]
        }
        game.compute_vr_platforms
        expect(game.vr_platforms).to eq [:vive, :rift, :osvr]
      end

      it 'should add Oculus if it has an Oculus game' do
        game = build_multigame steam: {
          vr_platforms: [:vive]
        }, oculus: {}
        game.compute_vr_platforms
        expect(game.vr_platforms).to eq [:vive, :rift]
      end
    end

    describe '#compute_players' do
      describe 'Steam game player flags' do
        {
          single_player:        [:single],
          multi_player:         [:multi],
          local_multi_player:   [:multi],
          online_multi_player:  [:multi, :online],
          co_op:                [:multi, :co_op],
          online_co_op:         [:multi, :co_op, :online],
          local_co_op:          [:multi, :co_op, :shared],
          shared_screen:        [:multi, :shared],
          cross_platform_multi: [:multi, :cross_platform]
        }.each_pair do |source_flag, expectation|
          it "should map Steam #{source_flag} to #{expectation} flag" do
            game = build_multigame steam: {
              players: [source_flag]
            }
            game.compute_players
            expect(game.players).to match_array expectation
          end
        end
      end

      describe 'Oculus game player flags' do
        {
          'SINGLE_USER' => [:single],
          'MULTI_USER' => [:multi],
          'CO_OP' => [:multi, :co_op]
        }.each_pair do |source_flag, expectation|
          it "should map Oculus #{source_flag} to #{expectation} flag" do
            game = build_multigame oculus: {
              players: [source_flag]
            }
            game.compute_players
            expect(game.players).to match_array expectation
          end
        end
      end
    end

    describe '#compute_vr_modes' do
      describe 'Steam VR modes flags' do
        it 'should read all the Steam flags' do
          game = build_multigame steam: {
            vr_mode: [:seated, :standing, :room_scale]
          }
          game.compute_vr_modes
          expect(game.vr_modes).to match_array [:seated, :standing, :room_scale]
        end
      end

      describe 'Oculus VR modes flags' do
        it 'should read all the Steam flags' do
          game = build_multigame oculus: {
            vr_mode: ['SITTING', 'STANDING', 'ROOM_SCALE']
          }
          game.compute_vr_modes
          expect(game.vr_modes).to match_array [:seated, :standing, :room_scale]
        end
      end
    end
  end

  describe '#compute_vr_only' do
    it 'should read it from Steam' do
      game = build_multigame steam: {
        vr_only: true
      }
      game.compute_vr_only
      expect(game.vr_only).to eq true
    end

    it 'should be set to true if on the Oculus store' do
      game = build_multigame oculus: {}
      game.compute_vr_only
      expect(game.vr_only).to eq true
    end
  end

  describe '#compute_playtime_stats' do
    describe '#playtime_mean' do
      it 'should be the mean value of the playtime' do
        game = build_multigame steam: {
          positive_reviews: [1,2,3,4,5],
          negative_reviews: []
        }
        game.compute_all
        expect(game.playtime_mean).to eq (1+2+3+4+5).to_f/5
      end
    end

    describe '#playtime_median' do
      it 'should be the mean value of the playtime' do
        game = build_multigame steam: {
          positive_reviews: [1,2,5],
          negative_reviews: [3,4]
        }
        game.compute_all
        expect(game.playtime_median).to eq 3
      end
    end

    describe '#playtime_sd' do
      it 'should be the mean value of the playtime' do
        game = build_multigame steam: {
           positive_reviews: [1,2,5],
           negative_reviews: [3,4]
        }
        game.compute_all
        expect(game.playtime_sd.round(2)).to eq 1.41
      end
    end

    describe '#playtime_rsd' do
      it 'should be the mean value of the playtime' do
        game = build_multigame steam: {
          positive_reviews: [1,2,5], negative_reviews: [3,4]
        }
        game.compute_all
        expect(game.playtime_rsd).to be_within(1).of(47)
      end
    end

    describe '#playtime_mean_ftb' do
      it 'should return the mean playtime for the buck' do
        game = build_multigame steam: {
          positive_reviews: [1,2,5],
          negative_reviews: [3,4,6],
          price: 400,
          sale_price: 300
        }
        game.compute_all
        mean = (1+2+3+4+5+6).to_f/6
        expect(game.playtime_mean_ftb).to eq mean/3
      end
    end

    describe '#playtime_median_ftb' do
      it 'should return the median playtime for the buck' do
        game = build_multigame steam: {
          positive_reviews: [1,2,5],
          negative_reviews: [3,4,6,7],
          price: 400,
          sale_price: 300
        }
        game.compute_all
        expect(game.playtime_median_ftb).to eq 4.0/3
      end
    end
  end

  describe '#compute_tags' do
    after :each do
      Tag.delete_tags_cache
    end

    it 'should create new tags when assigning non-existing tags' do
      game = build_multigame steam: {
        tags: ['potato', 'galaxy']
      }
      game.compute_tags
      expect(Tag.pluck(:name)).to eq ['potato', 'galaxy']
      expect(game.tags).to eq Tag.pluck(:id)
    end

    it 'should reuse existing tags when assigning existing tags' do
      t1 = create :tag, name: 'galaxy'
      game = build_multigame steam: {
        tags: ['potato', 'galaxy']
      }
      game.compute_tags
      t2 = Tag.last
      expect(t2.name).to eq 'potato'
      expect(game.tags).to eq [t2.id, t1.id]
    end

    it 'should be case insensitive' do
      t1 = create :tag, name: 'GALAXY'
      game = build_multigame steam: {
        tags: ['potato', 'galaxy']
      }
      game.compute_tags
      t2 = Tag.last
      expect(t2.name).to eq 'potato'
      expect(game.tags).to eq [t2.id, t1.id]
    end

    it 'should also use the tags from Oculus' do
      game = build_multigame oculus: {
        genres: ['potato', 'galaxy']
      }
      game.compute_tags
      expect(Tag.pluck(:name)).to eq ['potato', 'galaxy']
      expect(game.tags).to eq Tag.pluck(:id)
    end

    it 'should intercalate Oculus and Steam tags if both are available' do
      game = build_multigame steam: {
        tags: ['orange', 'banana', 'kiwi', 'melon']
      }, oculus: {
        genres: ['potato', 'galaxy']
      }
      game.compute_tags

      ids = ['orange', 'potato', 'banana', 'galaxy', 'kiwi', 'melon'].map do |name|
        Tag.find_by_name(name).id
      end

      expect(game.tags).to eq ids
    end

    it 'should ignore repeated tags, and keep the first occurence' do
      game = build_multigame steam: {
        tags: ['potato']
      }, oculus: {
        genres: ['galaxy', 'potato']
      }
      game.compute_tags
      expect(Tag.count).to eq 2
      expect(game.tags.size).to eq 2
      expect(game.tags).to eq([
        Tag.find_by_name('potato').id,
        Tag.find_by_name('galaxy').id
      ])
    end
  end

  describe '#compute_images' do
    it 'should get the images from both Oculus and Steam, prioritise Steam' do
      game = build_multigame steam: {
        images: ['http://purple.com']
      }, oculus: {
        screenshots: ['http://example.com']
      }
      game.compute_images
      expect(game.images).to eq ['http://purple.com']
    end

    it 'should get the images from Oculus if Steam not available' do
      game = build_multigame oculus: {
        screenshots: ['http://example.com']
      }
      game.compute_images
      expect(game.images).to eq ['http://example.com']
    end
  end

  describe '#compute_videos' do
    it 'should add videos from Oculus and Steam' do
      game = build_multigame steam: {
        videos: ['http://purple.com']
      }, oculus: {
        trailer_video: 'http://example.com'
      }
      game.compute_videos

      expect(game.videos).to eq ['http://purple.com', 'http://example.com']
    end
  end

  describe '#compute_thumbnail' do
    it 'should get the thumbnail from Steam' do
      game = build_multigame steam: {
        thumbnail: 'http://purple.com'
      }, oculus: {
        thumbnail: 'http://example.com'
      }
      game.compute_thumbnail

      expect(game.thumbnail).to eq 'http://purple.com'
    end

    it 'should get the thumbnail from Oculus if not available from Steam' do
      game = build_multigame oculus: {
        thumbnail: 'http://example.com'
      }
      game.compute_thumbnail

      expect(game.thumbnail).to eq 'http://example.com'
    end
  end

  describe '#compute_sysreq_string' do
    it 'should save the video sysreq information from Steam and Oculus to #sysreq_gpu' do
      game = build_multigame steam: {
        system_requirements: {
          minimum: { video_card: 'intel HD 4000' },
          recommended: { video_card: 'nvidia 970' }
        }
      }, oculus: {
        sysreq_gpu: 'geforce 970'
      }
      game.compute_sysreq_string
      expect(game.sysreq_gpu_string).to eq 'intel HD 4000 | nvidia 970 | geforce 970'
    end
  end

  describe '#compute_sysreq_tokens' do
    it 'should use the VideoCardAnalyzer to extract tokens from the #sysreq_gpu_string' do
      game = build_multigame
      game.released_at = Time.parse('2015-06-04')
      game.sysreq_gpu_string = 'intel HD 4000 | nvidia 970 | geforce 970'
      game.compute_sysreq_tokens

      expect(game.sysreq_gpu_tokens).to eq 'intel4000 nvidia970 year2015'
    end
  end

  describe '.compute_sysreq_indexes' do
    it 'should load the sysreq tokens of all games, calculate the values, and assign them' do
      g1 = create :game, sysreq_gpu_tokens: "really does not matter"
      g2 = create :game, sysreq_gpu_tokens: "other stuff"
      g3 = create :game, sysreq_gpu_tokens: ""
      g4 = create :game, sysreq_gpu_tokens: nil

      known_tokens = {
        'intel4000' => 800,
        'nvidia970' => 1700,
        'amd4000' => 1500
      }

      sysanal = double('SysreqAnalyzer')
      expect(sysanal).to receive(:get_list_values_averages).and_return(
        [1000, 300]
      )

      expect(Gpu).to receive(:get_tokens_hash).and_return(known_tokens)
      expect(SysreqAnalyzer).to receive(:new).with(
        [['really', 'does', 'not', 'matter'], ['other', 'stuff'], []],
        known_tokens
      ).and_return sysanal

      Game.mass_compute_sysreq_index

      g1.reload
      g2.reload

      expect(g1.sysreq_index).to eq 1000
      expect(g2.sysreq_index).to eq 300
      expect(g3.sysreq_index).to eq nil
      expect(g4.sysreq_index).to eq nil
    end
  end

  describe '.compute_percentiles' do
    describe '#sysreq_index_pct' do
      it 'should calculate the percentiles from #sysreq_index' do
        values = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]
        games = values.map do |val|
          create :game, sysreq_index: val
        end

        Game.compute_percentiles
        values_pct = Percentiles.rank_of_values(values)

        values_pct.each_with_index do |val, i|
          games[i].reload
          expect(games[i].sysreq_index_pct).to eq val
        end
      end
    end

    describe '#ratings_pct' do
      it 'should calculate the percentiles averages from #ratings_count and #ratings_ratio' do
        counts = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900]
        ratios = [nil, 20, 50, 80, 99, 99, 80, 70, 60, 86]

        counts_pct = Percentiles.rank_of_values(counts)
        ratios_pct = Percentiles.rank_of_values(ratios.reject{|a| a == nil})
        ratios_pct.unshift(nil)

        games = counts.each_with_index.map do |count, i|
          create :game, ratings_count: count, ratings_ratio: ratios[i]
        end

        Game.compute_percentiles

        games.each_with_index do |g, i|
          g.reload
          count_pct = counts_pct[i]
          ratio_pct = ratios_pct[i]
          if ratio_pct != nil
            expect(g.ratings_pct).to eq(((count_pct + ratio_pct).to_f / 2).round)
          else
            expect(g.ratings_pct).to eq(count_pct)
          end
        end
      end
    end
  end

  describe '.compute_urls' do
    it 'should have the Oculus URL' do
      game = build_multigame oculus: {
        oculus_id: '123123123123123'
      }
      game.compute_urls
      expect(game.urls).to eq({
        'oculus' => "https://www.oculus.com/experiences/rift/123123123123123/"
      })
    end

    it 'should have the Steam URL' do
      game = build_multigame steam: {
        steam_id: '321321'
      }
      game.compute_urls
      expect(game.urls).to eq({
        'steam' => "http://store.steampowered.com/app/321321/"
      })
    end

    it 'should have both URLs' do

    end
  end
end
