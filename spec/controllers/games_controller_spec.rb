describe GamesController, type: :controller do
  describe 'columns selection' do
    it 'should return only the selected columns' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Salad'
      get :index, format: :json, columns: ['id', 'name']

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'Potato'},
        {'id' => g2.id, 'name' => 'Salad'}
      ])
    end

    it 'should only allow certain columns' do
      g1 = create :game, name: 'Potato'
      g2 = create :game, name: 'Salad'
      get :index, format: :json, columns: ['id', 'name', 'potato']

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
      get :index,
        format: :json,
        columns: ['id', 'name'],
        filters: {name: { value: 'Pot', filter: true, highlight: false }}

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

      get :index,
        format: :json,
        columns: ['name'],
        sort: 'name_asc'

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

      get :index,
        format: :json,
        columns: ['name'],
        sort: 'name_desc'

      expect(response_json).to eq([
        {'id' => g1.id, 'name' => 'Potato'},
        {'id' => g3.id, 'name' => 'Pelotudo'},
        {'id' => g2.id, 'name' => 'Patota'},
      ])
    end

    it 'should sort by ascending steam_id by default' do
      g1 = create :game, steam_id: 123, name: 'Potato'
      g2 = create :game, steam_id: 50, name: 'Patota'
      g3 = create :game, steam_id: 66, name: 'Pelotudo'

      get :index,
        format: :json,
        columns: ['steam_id'],
        sort: 'rsahtirashtners'

      expect(response_json).to eq([
        {'id' => g2.id, 'steam_id' => 50},
        {'id' => g3.id, 'steam_id' => 66},
        {'id' => g1.id, 'steam_id' => 123},
      ])
    end

    it 'should put the nulls at the begining when ascending' do
      g1 = create :game, steam_id: 123
      g2 = create :game, steam_id: 50
      g3 = create :game, steam_id: 66
      g4 = create :game, steam_id: nil

      get :index,
        format: :json,
        columns: ['steam_id'],
        sort: 'steam_id_asc'

      expect(response_json).to eq([
        {'id' => g4.id, 'steam_id' => nil},
        {'id' => g2.id, 'steam_id' => 50},
        {'id' => g3.id, 'steam_id' => 66},
        {'id' => g1.id, 'steam_id' => 123},
      ])
    end

    it 'should put the nulls at the end when descending' do
      g1 = create :game, steam_id: 123
      g2 = create :game, steam_id: 50
      g3 = create :game, steam_id: 66
      g4 = create :game, steam_id: nil

      get :index,
        format: :json,
        columns: ['steam_id'],
        sort: 'steam_id_desc'

      expect(response_json).to eq([
        {'id' => g1.id, 'steam_id' => 123},
        {'id' => g3.id, 'steam_id' => 66},
        {'id' => g2.id, 'steam_id' => 50},
        {'id' => g4.id, 'steam_id' => nil},
      ])
    end
  end
end
