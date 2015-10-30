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
end
