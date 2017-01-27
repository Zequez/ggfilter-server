class ScrapingTask
  class << self
    def task_name(n = nil)
      @task_name = n ? n : @task_name
    end
  end

  def task_name
    self.class.task_name
  end

  def initialize(instant_fail = false)
    @instant_fail = instant_fail
    @max_saves_failure = 10
    @save_fail_count = 0

    if @instant_fail
      Scrapers::BasicRunner.instant_raise = true
    end
  end

  def scraper
    raise 'Virtual method'
  end

  def process(output)
    save(output)
    after_save(output)
  end

  def save(output)
    if output.respond_to? :each
      output.each_with_index do |attributes, i|
        rescue_save_fail do
          i += 1
          if i % 100 == 0 || i === output.size
            Scrapers.logger.ln "Saving #{i}/#{output.size}"
          end
          save_each(attributes)
        end
      end
    end
  end

  def save_each(attributes)

  end

  def after_save(output)

  end

  def rescue_save_fail(&cb)
    begin
      cb.call()
    rescue StandardError => e
      raise if @instant_fail
      @save_fail_count += 1
      @report.errors.push e
      if @save_fail_count > @max_saves_failure
        raise "Saving aborted, too many errors"
      end
    end
  end

  def run
    scrap_log = ScrapLog.new({
      started_at: Time.now,
      task_name: task_name
    })


    @report = scraper.run # this should NEVER fail, all the errors on #errors

    begin
      if @report.output
        process(@report.output)
      end
    rescue StandardError => e
      raise if @instant_fail
      @report.errors.push e
    end

    if @report.errors?
      scrap_log.error = true
      reporter = ErrorsReporter.new self.task_name
      reporter.errors = @report.errors
      reporter.warnings = @report.warnings
      reporter.commit
    end

    scrap_log.apply_report(@report)
    scrap_log.save!
  end
end
