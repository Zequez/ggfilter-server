describe Flaggable do
  with_model :GameModel do
    table do |t|
      t.integer :platforms, default: 0, null: false
    end

    model do
      include Flaggable

      flag_column :platforms, {
        win:   0b001,
        mac:   0b010,
        linux: 0b100
      }
    end
  end

  it 'should be empty by default' do
    expect(GameModel.new.platforms).to eq []
  end

  it 'should let you save data' do
    game = GameModel.new
    game.platforms = [:mac, :linux]
    expect(game.read_attribute(:platforms)).to eq 0b110
    expect(game.platforms).to match_array [:mac, :linux]
  end

  it 'should define the list of flags' do
    expect(GameModel.platforms_flags).to eq({
      win:   0b001,
      mac:   0b010,
      linux: 0b100
    })
  end

  it 'should let you get a join list of flags' do
    expect(GameModel.platforms_flags(:win, :linux)).to eq 0b101
  end

  it 'should define the reverse list of flags' do
    expect(GameModel.flags_platforms).to eq({
      0b001 => :win,
      0b010 => :mac,
      0b100 => :linux
    })
  end
end
