class Scrapers::BaseRunner
  attr_reader(:options)
  class_attribute :options
  self.options = {}


  def initialize(options)
    @options = self.class.options.merge(options)
  end
end
