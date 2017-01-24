require 'scrapers_definitions'
require 'rake'

class ScrapingDirector
  TASKS = ScrapersDefinitions.new

  attr_reader :runner
  alias_attribute :scraper, :runner

  def initialize(runner, task_name = nil)
    @task_name = task_name
    @runner = runner
  end

  def run
    @report = runner.run
    @report.report_errors_if_any
    if @report.output
      # TODO: This is quite hacky, shitty and brittle, let's just refactor later
      if @report.output[0].is_a? ActiveRecord::Base
        games = @report.output
      else
        games = @report.output.map{ |data| OculusGame.from_scraper! data }
      end

      @report.output.each(&:propagate_to_game)
    end
    scrap_log = ScrapLog.build_from_report(@report, @task_name)
    scrap_log.save!
  end

  def self.task(task_name)
    new TASKS.send(task_name), task_name.to_s
  end

  def self.tasks!
    RakeTasks.new.tasks!
  end

  class RakeTasks
     include Rake::DSL

     def tasks!
       namespace :scrap do
         ScrapersDefinitions.instance_methods(false).each do |method|
           desc "Scrap #{method.to_s.humanize}"
           task method => :environment do
             ScrapingDirector.task(method).run
           end
         end
       end
     end
  end
end
