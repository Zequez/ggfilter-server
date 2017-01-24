describe ScrapingDirector do
  describe '.steam_list' do
    it 'should be a Steam::List' do
      expect(ScrapingDirector.task(:steam_list).scraper)
        .to be_kind_of Scrapers::Steam::List::Runner
    end
  end

  describe '.steam_list_on_sale' do
    it 'should be a Steam::List' do
      expect(ScrapingDirector.task(:steam_list_on_sale).scraper)
        .to be_kind_of Scrapers::Steam::List::Runner
    end
  end

  describe '.steam_games' do
    it 'should be a Steam::Game' do
      expect(ScrapingDirector.task(:steam_games).scraper)
        .to be_kind_of Scrapers::Steam::Game::Runner
    end
  end

  describe '.steam_reviews' do
    it 'should be a Steam::Reviews' do
      expect(ScrapingDirector.task(:steam_reviews).scraper)
        .to be_kind_of Scrapers::Steam::Reviews::Runner
    end
  end

  describe '.benchmarks' do
    it 'should be a Benchmarks' do
      expect(ScrapingDirector.task(:benchmarks).scraper)
        .to be_kind_of Scrapers::Benchmarks::Runner
    end
  end

  # describe '.tasks' do
  #   it 'should generate a rake task for each scraper generator' do
  #
  #   end
  # end

  describe 'logging' do
    it 'should create a new scrap_log with the scrap report returned' do
      runner = double('Runner', run: ->{})
      report = double('ScrapReport')
      expect(report).to receive(:report_errors_if_any)
      expect(report).to receive(:output).and_return(nil)
      scrap_log = double('ScrapLog')
      expect(runner).to receive(:run).and_return(report)
      expect(scrap_log).to receive(:save!)
      expect(ScrapLog).to receive(:build_from_report).with(report, 'potato')
        .and_return(scrap_log)
      ScrapingDirector.new(runner, 'potato').run
    end
  end
end
