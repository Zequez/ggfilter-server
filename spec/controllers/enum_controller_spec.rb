describe EnumController, type: :controller do
  it 'should return an object with all the Game flags values' do
    get :index, format: :json
    expect(response_json.keys).to match_array([
      "stores",
      "players",
      "controllers",
      "vr_platforms",
      "vr_modes",
      "platforms",
      "gamepad"
    ])
  end
end
