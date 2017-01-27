describe ErrorsReporter do
  it 'should build with a task name' do
    expect{ ErrorsReporter.new('scrap_games') }.to_not raise_error
  end

  it 'should save errors to the filesystem' do
    tmpdir = Dir.tmpdir
    reporter = ErrorsReporter.new 'scrap_games', filesystem: tmpdir

    reporter.add_warning "Yo this is a warning I'm warning you"

    scrap_error = double 'ScrapError',
      message: 'POP POP',
      backtrace: 'BACK BOO',
      html: 'woo',
      url: 'http://example.com'
    normal_exception = double 'Exception',
      backtrace: 'BACK BACK!',
      message: 'WAKA WAKA'

    reporter.add_error scrap_error
    reporter.add_error normal_exception

    stub_request(:post, 'https://api.sendgrid.com/v3/mail/send')

    reporter.commit

    assert_requested :post, 'https://api.sendgrid.com/v3/mail/send', body: /POP POP/

    file_name = reporter.name(scrap_error)
    html_file = tmpdir + '/' + file_name + '.html'
    json_file = tmpdir + '/' + file_name + '.json'

    expect(File.exists? html_file).to eq true
    expect(File.exists? json_file).to eq true

    expect(File.read html_file).to eq 'woo'
    expect(JSON.parse(File.read json_file)).to eq({
      time: reporter.timestamp,
      errors: [{
        msg: 'POP POP',
        backtrace: 'BACK BOO',
        url: 'http://example.com',
      }.stringify_keys, {
        msg: 'WAKA WAKA',
        backtrace: 'BACK BACK!',
        url: nil,
      }.stringify_keys],
      warnings: ["Yo this is a warning I'm warning you"]
    }.stringify_keys)
  end
end
