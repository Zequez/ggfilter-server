describe SysreqToken, type: :model do
  describe '.analyze_games' do
    it 'should read the games tokens and generate the rows' do
      create :sysreq_token, name: 'intel4000', games_count: 300, token_type: :gpu

      create :game, system_requirements: { minimum: { video_card: 'intel hd4000 nvidia 980 ati 3000' } }
      create :game, system_requirements: { minimum: { video_card: 'intel hd4400 nvidia 930 ati 3000' } }
      create :game, system_requirements: { minimum: { video_card: 'intel hd4000 nvidia 910 ati 3000' } }

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
      g1 = create :game, system_requirements: { recommended: { video_card: 'intel hd4000' } }
      g2 = create :game, system_requirements: { recommended: { video_card: 'intel hd4400' } }
      g3 = create :game, system_requirements: { recommended: { video_card: 'intel hd4000' } }

      SysreqToken.analyze_games
      tokens = SysreqToken.all.order('games_count ASC')
      expect(tokens[0].games).to match_array [g2]
      expect(tokens[1].games).to match_array [g1, g3]
    end
  end

  describe '.with_loaded_games' do
    it 'should return the SysreqToken with the #games already loaded' do
      g1 = create :game, system_requirements: { recommended: { video_card: 'intel hd4000' } }
      g2 = create :game, system_requirements: { recommended: { video_card: 'intel hd4400' } }
      g3 = create :game, system_requirements: { recommended: { video_card: 'intel hd4000' } }

      SysreqToken.analyze_games
      tokens = SysreqToken.all.order('games_count ASC').with_loaded_games
      expect(tokens[0].instance_variable_get :@games).to match_array [g2]
      expect(tokens[1].instance_variable_get :@games).to match_array [g1, g3]
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
end
