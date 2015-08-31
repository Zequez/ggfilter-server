require 'nokogiri'

module Scrapers
  class BasePageProcessor
    def initialize(response, &add_to_queue)
      @response = response
      @request = response.request
      @url = response.request.url
      @doc = Nokogiri::HTML(response.body)
      @add_to_queue = add_to_queue
    end

    attr_accessor :data

    def process_page
      raise NotImplementedError.new('#process_page is an abstract method')
    end

    def add_to_queue(url)
      @add_to_queue.call(url)
    end

    def self.regexp(value = nil)
      (@regexp = value if value) || @regexp || /(?!)/
    end
  end
end
