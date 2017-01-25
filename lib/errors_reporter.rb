require 'json'
require 'sendgrid-ruby'
require "base64"

class ErrorsReporter
  def initialize(task_name, config = {})
    @task_name = task_name
    @config = {
      filesystem: 'log/scrap_errors',
      email: ENV['ERROR_REPORT_EMAIL'],
      email_from: 'noreply@ggfilter.com'
    }.merge(config)

    @errors_msg = []
    @errors = []
    @warnings = []
  end

  def add_error(exception, additional_msg = nil)
    @errors.push exception
    @errors_msg.push additional_msg
  end

  def add_warning(msg)
    @warnings.push msg
  end

  def commit
    L @config
    save! if @config[:filesystem]
    email! if @config[:email]
  end

  def timestamp
    @time ||= Time.now.strftime('%Y%m%d-%H%M%S')
  end

  def title
    "#{@task_name} | #{@errors.size} errors | #{@warnings.size} warnings | #{timestamp}"
  end

  def name(e)
    url = e.url
      .sub(/^https?:\/\//, '')
      .sub(/\?.*$/, '')
      .gsub(/[\x00\/\\:\*\?\"<>\|.]/, '_')

    "#{timestamp}_#{@task_name}_#{url}.html"
  end

  def body
    JSON.pretty_generate({
      time: timestamp,
      errors: @errors.each_with_index.map do |e, i|
        {
          msg: e.message,
          backtrace: e.backtrace,
          url: (e.url if e.respond_to? :url),
          additional_msg: @errors_msg[i]
        }
      end,
      warnings: @warnings
    })
  end

  def page(e)
    e.html.force_encoding('utf-8')
  end

  def files
    @errors.select{ |e| e.respond_to? :html }.map do |e|
      attachment = SendGrid::Attachment.new
      attachment.content = Base64.strict_encode64(page(e))
      attachment.type = 'text/html'
      attachment.filename = name(e) + '.html'
    end
  end

  def save!
    @errors.each do |e|
      if e.respond_to? :html
        file_path = Rails.root.join(@config[:filesystem])
        FileUtils.mkdir_p file_path
        File.write("#{file_path}/#{name(e)}.json", body)
        File.write("#{file_path}/#{name(e)}.html", page(e))
      end
    end
  end

  def email!
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

    from = SendGrid::Email.new(email: @config[:email_from])
    to = SendGrid::Email.new(email: @config[:email])
    content = SendGrid::Content.new(type: 'text/plain', value: body)
    mail = SendGrid::Mail.new(from, title, to, content)

    mail.attachments = files

    L mail

    sg.client.mail._('send').post(request_body: mail.to_json)
  end
end
