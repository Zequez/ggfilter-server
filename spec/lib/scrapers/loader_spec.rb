describe Scrapers::Loader do
  let(:s){ Scrapers }

  describe '#new' do
    it 'should accept an URL as the first argument and a list of processors as the second argument' do
      expect{ s::Loader.new('http::/potato.com', s::BasePageProcessor) }.to_not raise_error
    end
  end

  describe '#scrap', cassette: true do
    it 'should raise a NoPageProcessorFoundError error if no processor was found for the page' do
      scraper = s::Loader.new('http://www.purple.com', s::BasePageProcessor)
      expect{scraper.scrap}.to raise_error s::NoPageProcessorFoundError
    end

    it 'should process each page and return an array of the processed data' do
      class ExtendedProcessor < s::BasePageProcessor
        regexp %r{http://www\.purple\.com}

        def process_page
          'Yeaaaah!'
        end
      end

      scraper = s::Loader.new('http://www.purple.com', ExtendedProcessor)
      expect(scraper.scrap).to eq ['Yeaaaah!']
    end

    it 'should process each page and return concatenation of the arrays of the processed array data' do
      class ExtendedProcessor < s::BasePageProcessor
        regexp %r{http://www\.purple\.com}

        def process_page
          ['Yeaaaah!', 'Potato!']
        end
      end

      scraper = s::Loader.new('http://www.purple.com', ExtendedProcessor)
      expect(scraper.scrap).to eq ['Yeaaaah!', 'Potato!']
    end

    it 'should return a hash with the URLs if multiple URLs were provided' do
      class ExtendedProcessor1 < s::BasePageProcessor
        regexp %r{http://www\.purple\.com}

        def process_page
          'Purple is the best!'
        end
      end

      class ExtendedProcessor2 < s::BasePageProcessor
        regexp %r{http://www\.zombo\.com}

        def process_page
          'Welcome to Zombocom!'
        end
      end

      scraper = s::Loader.new(
        ['http://www.zombo.com', 'http://www.purple.com'],
        [ExtendedProcessor1, ExtendedProcessor2]
      )
      expect(scraper.scrap).to eq({
        'http://www.zombo.com' => ['Welcome to Zombocom!'],
        'http://www.purple.com' => ['Purple is the best!']
      })
    end

    it 'should yield the data as each page loads to a block given in scrap' do
      class Processor < s::BasePageProcessor
        regexp %r{.}

        def process_page
          @@count ||= 0
          @@count += 1
        end
      end

      scraper = s::Loader.new(
        ['http://www.zombo.com', 'http://www.purple.com', 'http://www.purple.com/potato'],
        [Processor]
      )

      # Couldn't find a way to test calls that worked with currying
      testYieldBlock = lambda{|data, initial_url, url|}
      yieldBlock = lambda do |data, initial_url, url|
        testYieldBlock.call(data, initial_url, url)
      end

      expect(testYieldBlock).to receive(:call).with(1, 'http://www.zombo.com', 'http://www.zombo.com')
      expect(testYieldBlock).to receive(:call).with(2, 'http://www.purple.com', 'http://www.purple.com')
      expect(testYieldBlock).to receive(:call).with(3, 'http://www.purple.com/potato', 'http://www.purple.com/potato')
      scraper.scrap(&yieldBlock)
    end
  end
end
