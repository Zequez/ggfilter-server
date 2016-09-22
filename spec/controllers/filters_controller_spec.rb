describe FiltersController, type: :controller do
  as_json = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }


  describe 'create' do
    it 'should create a filter with the given filter object and a new SID' do
      post :create, {filter: {filter: {potato: "salad"}.to_json}}, as_json
      expect(Filter.first.filter).to eq '{"potato":"salad"}'
    end
  end

  describe 'show' do
    it 'should retrieve a filter from a SID' do
      f = create :filter
      get :show, id: f.sid
      expect(response.success?).to eq(true)
      expect(JSON.parse(response.body)['sid']).to eq(f.sid)
    end
  end
end
