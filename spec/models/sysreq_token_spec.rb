describe SysreqToken, type: :model do
  describe '.analyze_games' do
    it 'should read the games tokens and generate the rows' do
      create :sysreq_token, name: 'intel4000', games_count: 300, token_type: :gpu

      create :steam_game, system_requirements: { minimum: { video_card: 'intel hd4000 nvidia 980 ati 3000' } }
      create :steam_game, system_requirements: { minimum: { video_card: 'intel hd4400 nvidia 930 ati 3000' } }
      create :steam_game, system_requirements: { minimum: { video_card: 'intel hd4000 nvidia 910 ati 3000' } }

      SysreqToken.analyze_games
      tokens = SysreqToken.all.order('games_count ASC, name ASC')
      expect(tokens.size).to eq 6
      expect(tokens[0].name).to eq 'intel4400'
      expect(tokens[1].name).to eq 'nvidia910'
      expect(tokens[2].name).to eq 'nvidia930'
      expect(tokens[3].name).to eq 'nvidia980'
      expect(tokens[4].name).to eq 'intel4000'
      expect(tokens[5].name).to eq 'amd3000'
      expect(tokens[0].games_count).to eq 1
      expect(tokens[1].games_count).to eq 1
      expect(tokens[2].games_count).to eq 1
      expect(tokens[3].games_count).to eq 1
      expect(tokens[4].games_count).to eq 2
      expect(tokens[5].games_count).to eq 3
    end
  end

  describe '#games' do
    it 'should return all the games with this token' do
      g1 = create(:steam_game, system_requirements: { recommended: { video_card: 'intel hd4000' } }).game
      g2 = create(:steam_game, system_requirements: { recommended: { video_card: 'intel hd4400' } }).game
      g3 = create(:steam_game, system_requirements: { recommended: { video_card: 'intel hd4000' } }).game

      SysreqToken.analyze_games
      tokens = SysreqToken.all.order('games_count ASC')
      expect(tokens[0].games).to match_array [g2]
      expect(tokens[1].games).to match_array [g1, g3]
    end
  end

  describe '.values_from_gpus_benchmarks!' do
    it 'should extract values from the GPUs benchmarks' do
      Gpu.create name: 'Radeon HD 8950', value: 100
      token = create :sysreq_token, name: 'amd8950', value: 10
      SysreqToken.values_from_gpus_benchmarks!
      token.reload
      expect(token.value).to eq 100
      expect(token.source).to eq :gpu_benchmarks
    end
  end

  describe '#linked_to' do
    it 'should set the value to the average of the value of the tokens specified on this attribute' do
      create :sysreq_token, name: 'intel4000', value: 300
      create :sysreq_token, name: 'intel4400', value: 500
      t = create :sysreq_token, name: 'intel4xxx', linked_to: 'intel4000 intel4400'
      expect(t.value).to eq 400
    end
  end

  describe '.link_wildcards!' do
    it 'should link tokens with xxx with the corresponding other tokens' do
      create :sysreq_token, name: 'intel4000', value: 300
      create :sysreq_token, name: 'intel4400', value: 500
      t = create :sysreq_token, name: 'intel4xxx'
      SysreqToken.link_wildcards!
      t.reload
      expect(t.linked_to).to eq 'intel4000 intel4400'
      expect(t.value).to eq 400
      expect(t.source).to eq :wildcard
    end
  end

  describe '#infer_value' do
    it 'should set the value of the average of all the other tokens of games that contain this token' do
      create :sysreq_token, name: 'intel4000', value: 100, source: :gpu_benchmarks
      create :sysreq_token, name: 'intel4400', value: 200, source: :gpu_benchmarks
      create :sysreq_token, name: 'amd7000', value: 300, source: :gpu_benchmarks
      create :sysreq_token, name: 'nvidia8000', value: 400, source: :gpu_benchmarks
      create :sysreq_token, name: 'nvidia8300', value: 500, source: :gpu_benchmarks
      create :sysreq_token, name: 'potato', value: 600, source: :manual
      token = create :sysreq_token, name: '800x600', value: nil, source: :none

      create :game, sysreq_video_tokens: 'intel4000 intel4400 amd7000 800x600'
      create :game, sysreq_video_tokens: 'nvidia8000'
      create :game, sysreq_video_tokens: 'nvidia8300 intel4400 potato 800x600'
      create :game, sysreq_video_tokens: '800x600'

      token.infer_value
      expect(token.value).to eq (100+200+300+500+600).to_f/5 # 340
      expect(token.source).to eq :inferred
    end
  end

  describe '#infer_projection_resolution' do
    it 'should use the projected value from the pixels count' do
      create :sysreq_token, name: '800x600', value: 1200, source: :inferred # 480,000
      create :sysreq_token, name: '300x500', value: 500, source: :inferred # 150,000
      create :sysreq_token, name: '150x150', value: 100, source: :inferred # 22,500
      token = SysreqToken.new name: '50x50', source: :none
      token.infer_projection_resolution
      slr = SimpleLinearRegression.new [800*600, 300*500, 150*150], [1200, 500, 100]
      expect(token.value).to eq (slr.y_intercept + slr.slope * 50*50).round
      expect(token.source).to eq :inferred_projection
    end
  end

  describe '#infer_projection_directx' do
    it 'should use the projected directX version' do
      create :sysreq_token, name: 'directx8', value: 229, source: :inferred # 8
      create :sysreq_token, name: 'directx9', value: 1213, source: :inferred # 9
      create :sysreq_token, name: 'directx10', value: 1714, source: :inferred # 10
      create :sysreq_token, name: 'directx11', value: 2227, source: :inferred # 10
      token = SysreqToken.new name: 'directx7', source: :none
      token.infer_projection_directx
      slr = SimpleLinearRegression.new [11, 10, 9, 8], [2227, 1714, 1213, 229]
      expect(token.value).to eq (slr.y_intercept + slr.slope * 7).round
      expect(token.source).to eq :inferred_projection
    end
  end

  # describe '#infer_projection_video_memory' do
  #   it 'should use the projected video memory' do
  #     create :sysreq_token, name: '15mb', value: 100, source: :inferred, games_count: 1 # 8
  #     create :sysreq_token, name: '1200mb', value: 300, source: :inferred, games_count: 2 # 9
  #     create :sysreq_token, name: '2gb', value: 800, source: :inferred, games_count: 1 # 10
  #     token = SysreqToken.new name: '1gb', source: :none
  #     token.infer_projection_video_memory
  #     slr = SimpleLinearRegression.new [2048, 1200, 1200, 15], [800, 300, 300, 100]
  #     expect(token.value).to eq (slr.y_intercept + slr.slope * 1024).round
  #     expect(token.source).to eq :inferred_projection
  #   end
  # end

  describe '.infer_values!' do
    # it 'call #infer_value for all :none or :inferred tokens' do
    #
    # end
  end
end
