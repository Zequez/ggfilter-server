class CustomLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end

  def l(msg)
    self << "#{msg.inspect}\n"
  end

  def la(msg)
    self << "#{msg.ai}\n"
  end

  def ln(msg)
    self << "#{msg}\n"
  end
end
