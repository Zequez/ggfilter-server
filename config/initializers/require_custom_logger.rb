LL = begin
  logfile = File.open("#{Rails.root}/log/custom.log", 'a')  # create log file
  logfile.sync = true  # automatically flushes data to file
  CustomLogger.new(logfile)  # constant accessible anywhere
end

define_method :L, &LL.method(:l)
define_method :LA, &LL.method(:la)
define_method :LN, &LL.method(:ln)
