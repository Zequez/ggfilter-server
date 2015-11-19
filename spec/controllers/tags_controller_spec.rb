describe TagsController, type: :controller do
  describe 'index' do
    it 'should return an indexed array with a list of tags' do
      t1 = create :tag, name: 'potato'
      t2 = create :tag, name: 'galaxy'
      t3 = create :tag, name: 'simulator'
      t4 = create :tag, name: '2015'
      a = []
      a[t1.id] = 'potato'
      a[t2.id] = 'galaxy'
      a[t3.id] = 'simulator'
      a[t4.id] = '2015'

      get :index, format: :json

      expect(response_json).to eq(a)
    end
  end
end
