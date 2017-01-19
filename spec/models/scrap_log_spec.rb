describe ScrapLog, type: :model do
  subject{ build :scrap_log }

  it { expect(subject).to respond_to(:started_at) }
  it { expect(subject).to respond_to(:finished_at) }
  it { expect(subject).to respond_to(:scraper) }
  it { expect(subject).to respond_to(:error) }
  it { expect(subject).to respond_to(:msg) }

  describe '.get_for_cleanup' do
    it 'should get the scrap logs previous to the last week' do
      create :scrap_log, started_at: Time.now - 5.days
      create :scrap_log, started_at: Time.now - 3.days

      expected = []
      expected.push create :scrap_log, started_at: Time.now - 1.month
      expected.push create :scrap_log, started_at: Time.now - 7.days
      expected.push create :scrap_log, started_at: Time.now - 1.year

      expect(ScrapLog.get_for_cleanup).to match_array expected
    end
  end

  describe '.for_index' do
    it 'should get all the scrap logs in descending :started_at order' do
      s1 = create :scrap_log, started_at: Time.now - 5.days
      s2 = create :scrap_log, started_at: Time.now - 1.month
      s3 = create :scrap_log, started_at: Time.now - 3.days

      expect(ScrapLog.for_index).to eq [s3, s1, s2]
    end
  end

  describe '.clean_logs' do
    it 'should delete the logs gotten from .get_for_cleanup' do
      expected = []

      expected.push create :scrap_log, started_at: Time.now - 5.days
      expected.push create :scrap_log, started_at: Time.now - 3.days
      create :scrap_log, started_at: Time.now - 1.month
      create :scrap_log, started_at: Time.now - 7.days
      create :scrap_log, started_at: Time.now - 1.year

      ScrapLog.clean_logs

      expect(ScrapLog.all).to match_array expected
    end
  end

  describe '.build_from_report' do
    it 'should save the start and end time from the report' do
      report = Scrapers::ScrapReport.new('super_scraper')
      report.start
      report.finish
      report.scraper_report = '10 games or something'

      scrap_log = ScrapLog.build_from_report(report, 'super_scraper_lite')

      expect(scrap_log.started_at).to eq report.started_at
      expect(scrap_log.finished_at).to eq report.finished_at
      expect(scrap_log.msg).to eq '10 games or something'
      expect(scrap_log.scraper).to eq 'super_scraper'
      expect(scrap_log.task_name).to eq 'super_scraper_lite'
      expect(scrap_log.error?).to eq false
    end

    it 'should save the error message for failed reports' do
      report = Scrapers::ScrapReport.new('super_scraper')
      report.start
      report.finish
      report.scraper_report = '10 games or something'
      report.error! Scrapers::Errors::ScrapError.new('Oops')

      scrap_log = ScrapLog.build_from_report(report, 'faulty')

      expect(scrap_log.started_at).to eq report.started_at
      expect(scrap_log.finished_at).to eq report.finished_at
      expect(scrap_log.msg).to eq 'Oops'
      expect(scrap_log.scraper).to eq 'super_scraper'
      expect(scrap_log.task_name).to eq 'faulty'
      expect(scrap_log.error?).to eq true
    end
  end
end
