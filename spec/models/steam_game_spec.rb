describe SteamGame, type: :model do
  it 'should create a new Game with the same name after being created' do
    create :steam_game, name: 'Potato Salad'
    expect(Game.first.name).to eq('Potato Salad')
  end

  it 'should not create or update a Game if the Game already exist' do
    g = create :game, name: 'Galaxy Simulator'
    updated_at = g.updated_at
    create :steam_game, name: 'Galaxy Simulator'
    expect(Game.count).to eq(1)
    g.reload
    expect(g.updated_at).to eq updated_at
  end

  it 'should make the Game loaded in the SteamGame' do
    sg = create :steam_game, name: 'Potato Salad'
    expect(sg.game).to_not be_nil
  end
end
