def valid_data(object = {})
  {
    oculus_id: 123123123,
    name: 'Potato',
    price: 999,
    price_regular: nil,
    released_at: 6.months.ago.iso8601,
    summary: 'This is a summary',
    version: '1.1.0',
    category: 'Action',
    genres: ['Potato', 'Galaxy'],
    languages: ['English', 'Potato Language'],
    age_rating: nil,
    developer: 'PotatoDev',
    publisher: 'PotatoStudio',
    vr_mode: ['STANDING'],
    vr_tracking: ['FRONT_FACING'],
    vr_controllers: ['OCULUS_TOUCH'],
    players: ['SINGLE_USER'],
    comfort: 'COMFORTABLE_FOR_MOST',
    internet: 'NOT_REQUIRED',
    sysreq_hdd: 123456789,
    sysreq_cpu: 'Intel Galaxy i5',
    sysreq_gpu: 'Nvidia Fire Universe 9999',
    sysreq_ram: 8,
    website_url: 'http://www.example.com',
    rating_1: 10,
    rating_2: 20,
    rating_3: 30,
    rating_4: 40,
    rating_5: 50,
    thumbnail: 'http://www.example.com',
    screenshots: ['http://example.com'],
    trailer_video: 'http://www.example.com',
    trailer_thumbnail: 'http://www.example.com'
  }.merge(object)
end

describe OculusGame, type: :model do
  def build_game!(attrs = {})
    OculusGame.from_scraper!(valid_data(attrs))
  end


  describe '.from_scraper!' do
    it 'should not allow to be created with an invalid data JSON schema' do
      expect{ build_game!(oculus_id: nil) }
        .to raise_error JSON::Schema::ValidationError
    end

    it 'should allow to be created with a valid data JSON schema' do
      expect{ build_game! }.to_not raise_error
    end
  end

  describe 'flaggable columns' do
    {
      vr_mode: ["SITTING", "STANDING", "ROOM_SCALE"],
      vr_tracking: ["DEGREE_360", "FRONT_FACING"],
      vr_controllers: [
        "OCULUS_TOUCH",
        "OCULUS_REMOTE",
        "GAMEPAD",
        "KEYBOARD_MOUSE",
        "FLIGHT_STICK",
        "RACING_WHEEL",
        "HYDRA"
      ],
      players: ["SINGLE_USER", "MULTI_USER", "CO_OP"]
    }.each_pair do |column, flags|
      it "#{column} should be flaggable" do
        g = build_game!

        g.send "#{column}=", []
        expect(g.send column).to eq []

        g.send "#{column}=", flags
        expect(g.send column).to eq flags
      end
    end
  end

  fdescribe 'serializable columns' do
    [:genres, :languages, :screenshots].each do |column|
      it "#{column} should be serializable" do
        data = valid_data
        original_value = data[column]
        build_game!.save!
        g = OculusGame.first
        expect(g.send column).to eq original_value
      end
    end

  end
end
