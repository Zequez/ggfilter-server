require 'typhoeus'

module Scrapers
  class Loader
    attr_reader :data

    def initialize(initial_url, processors)
      @processors = Array(processors)
      @initial_urls = Array(initial_url)
      @multi_urls = initial_url.kind_of? Array
      @hydra = Typhoeus::Hydra.hydra
      @urls_queued = []
    end

    def scrap
      @data = {}
      @initial_urls.each do |initial_url|
        @data[initial_url] = []
        add_to_queue initial_url, initial_url
      end
      @hydra.run

      @multi_urls ? @data : @data.values.first
    end

    private

    def process_response(response, initial_url, processor_class)
      processor = processor_class.new(response) do |url|
        add_to_queue(url, initial_url)
      end
      add_page_data processor.process_page, initial_url
    end

    def add_to_queue(url, initial_url)
      unless @urls_queued.include? url
        processor_class = find_processor_for_url(url)
        request = Typhoeus::Request.new(url)
        request.on_complete do |response|
          process_response response, initial_url, processor_class
        end
        @urls_queued << url
        @hydra.queue request
      end
    end

    def no_processor_error(url)
      available_processors_names = @processors.map{ |p| p.class.name }.join(', ')
      raise NoPageProcessorFoundError.new("Couldn't find processor for #{url} \n Available processors: #{available_processors_names}")
    end

    def add_page_data(page_data, initial_url)
      if page_data.kind_of? Array
        @data[initial_url].concat page_data
      else
        @data[initial_url].push page_data
      end
    end

    def find_processor_for_url(url)
      processor_class = @processors.detect{ |pc| pc.regexp.match url }
      return no_processor_error(url) unless processor_class
      processor_class
    end
  end
end
