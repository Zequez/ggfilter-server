describe ScrapLogsController, type: :controller do
  describe 'index' do
    it 'should return all the scrap logs in descending :started_at order' do
      scrap_logs = 25
        .times
        .to_a
        .reverse
        .map{ |i| create :scrap_log, started_at: i.days.ago }
        .reverse

      get :index, format: :json

      expect(response_json).to eq(JSON.parse(scrap_logs.to_json))
    end
  end
end
