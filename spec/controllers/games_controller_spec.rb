describe GamesController, type: :controller do
  def get_index(params)
    get :index,
      format: :json,
      params: params.merge({
        filter: JSON.dump(params[:filter]),
      })
  end

  describe 'columns selection' do
    it 'should return only the selected columns' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Salad'
      get_index filter: {params: {name: true}}

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'Potato'},
        {'id' => g2.id, 'name' => 'Salad'}
      ])
    end

    it 'should only allow certain columns' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Salad'
      get_index filter: {params: {name: true, potato: true}}

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'Potato'},
        {'id' => g2.id, 'name' => 'Salad'}
      ])
    end
  end

  describe 'filters' do
    it 'should be able to apply a name filter' do
      g1 = create :game, name: 'Potato'
      _g2 = create :game, name: 'Salad'
      get_index filter: {params: {name: {value: 'Pot'}}}

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'Potato'}
      ])
    end
  end

  describe 'sort' do
    it 'should allow you to sort ascending' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Patota'
      g3 = create :game, name: 'Pelotudo'

      get_index filter: {params: { name: true }, sort: { filter: 'name', asc: true }}

      expect(response_json).to eq([
        {'id' => g2.id, 'name' => 'Patota'},
        {'id' => g3.id, 'name' => 'Pelotudo'},
        {'id' => g1.id, 'name' => 'Potato'},
      ])
    end

    it 'should allow sort descending' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Patota'
      g3 = create :game, name: 'Pelotudo'

      get_index filter: {params: { name: true }, sort: { filter: 'name', asc: false }}

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'Potato'},
        {'id' => g3.id, 'name' => 'Pelotudo'},
        {'id' => g2.id, 'name' => 'Patota'},
      ])
    end

    it 'should sort by ascending steam_id by default' do
      g1 = create(:steam_game, steam_id: 123, name: 'Potato').game
      g2 = create(:steam_game, steam_id: 50, name: 'Patota').game
      g3 = create(:steam_game, steam_id: 66, name: 'Pelotudo').game

      get_index filter: {params: {steam_id: true}, sort: { filter: 'rsarsarsa' }}

      expect(response_json).to eq([
        {'id' => g2.id, 'steam_id' => 50},
        {'id' => g3.id, 'steam_id' => 66},
        {'id' => g1.id, 'steam_id' => 123},
      ])
    end

    it 'should put the nulls at the begining when ascending' do
      g1 = create(:game, name: 'c')
      g2 = create(:game, name: 'a')
      g3 = create(:game, name: 'b')
      g4 = create(:game, name: nil)

      get_index filter: {params: {name: true}, sort: {filter: 'name', asc: true}}

      expect(response_json).to eq([
        {'id' => g4.id, 'name' => nil},
        {'id' => g2.id, 'name' => 'a'},
        {'id' => g3.id, 'name' => 'b'},
        {'id' => g1.id, 'name' => 'c'},
      ])
    end

    it 'should put the nulls at the end when descending' do
      g1 = create(:game, name: 'c')
      g2 = create(:game, name: 'a')
      g3 = create(:game, name: 'b')
      g4 = create(:game, name: nil)

      get_index filter: {params: {name: true}, sort: {filter: 'name', asc: false}}

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'c'},
        {'id' => g3.id, 'name' => 'b'},
        {'id' => g2.id, 'name' => 'a'},
        {'id' => g4.id, 'name' => nil},
      ])
    end
  end
end
