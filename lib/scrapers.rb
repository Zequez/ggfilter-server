module Scrapers
  class NoPageProcessorFoundError < StandardError; end
  class InvalidProcessorError < StandardError; end

  def self.logger
    @logger ||= begin
      logfile = File.open("#{Rails.root}/log/scrapers.log", 'a')  # create log file
      logfile.sync = true  # automatically flushes data to file
      CustomLogger.new(logfile)  # constant accessible anywhere
    end
  end
end
