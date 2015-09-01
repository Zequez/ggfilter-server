describe Scrapers::SteamGame::PageProcessor, cassette: true do
  let(:processor_class) { Scrapers::SteamGame::PageProcessor }

  def steam_game_url(app_id)
    "http://store.steampowered.com/app/#{app_id}"
  end

  describe 'URL detection' do
    it 'should detect the Steam search result URLs' do
      url = steam_game_url(1)
      expect(url).to match processor_class.regexp
    end

    it 'should not detect non-steam search result URLs' do
      url = "http://store.steampowered.com/banana/123456"
      expect(url).to_not match processor_class.regexp
    end
  end
end
