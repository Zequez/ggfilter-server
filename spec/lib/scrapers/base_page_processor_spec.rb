describe Scrapers::BasePageProcessor, cassette: true do
  it 'should initialize with an HTTP response and a code block' do
    response = Typhoeus.get('http://www.purple.com')

    expect{
      Scrapers::BasePageProcessor.new(response) do |url|

      end
    }.to_not raise_error
  end

  describe '.regexp' do
    it 'should return a nonmatching regex by default' do
      expect(Scrapers::BasePageProcessor.regexp).to eq(/(?!)/)
    end

    it 'should save the regex when called with a value' do
      class ExtendedProcessor < Scrapers::BasePageProcessor
        regexp %r{potato}
      end
      expect(ExtendedProcessor.regexp).to eq(/potato/)
      expect(Scrapers::BasePageProcessor.regexp).to eq(/(?!)/)
    end
  end

  it 'should call the block given when calling #add_to_queue' do
    class ExtendedProcessor < Scrapers::BasePageProcessor
      def process_page
        add_to_queue('rsarsa')
      end
    end

    response = Typhoeus.get('http://www.purple.com')

    block = lambda{ |url| }
    expect(block).to receive(:call).with('rsarsa')

    processor = ExtendedProcessor.new(response, &block)
    processor.process_page
  end
end
