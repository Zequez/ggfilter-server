require 'scraping_tasks'
require 'rake'

class ScrapingTasksRake
  # TASKS = ScrapersDefinitions.new
  #
  # attr_reader :runner
  # alias_attribute :scraper, :runner
  #
  # def initialize(runner, task_name = nil)
  #   @task_name = task_name
  #   @runner = runner
  # end
  #
  # def run
  #   @report = runner.run
  #   @report.report_errors_if_any
  #   if @report.output
  #     # TODO: This is quite hacky, shitty and brittle, let's just refactor later
  #     if @report.output[0].is_a? ActiveRecord::Base
  #       games = @report.output
  #     else
  #       games = @report.output.map do |data|
  #         begin
  #           OculusGame.from_scraper! data
  #         rescue JSON::Schema::ValidationError => e
  #           puts "Game #{data[:name]} #{data[:oculus_id]} did not pass schema"
  #           puts e.message
  #           nil
  #         end
  #       end
  #       games = games.compact
  #     end
  #
  #     games.each(&:propagate_to_game)
  #   end
  #   scrap_log = ScrapLog.build_from_report(@report, @task_name)
  #   scrap_log.save!
  # end
  #
  # def self.task(task_name)
  #   new TASKS.send(task_name), task_name.to_s
  # end
  #
  # def self.tasks!
  #   ScrapingTasks
  #
  # end

  # class RakeTasks
  extend Rake::DSL

  def self.tasks!
    tasks = ScrapingTasks
      .constants
      .map{ |c| ScrapingTasks.const_get c }
      .select{ |c| c.respond_to? :task_name }

    namespace :scrap do

     tasks.each do |klass|
       desc "Scrap #{klass.task_name.to_s.humanize}"
       task(klass.task_name, [:fail] => :environment) do |t, args|
         instant_fail = !!args[:fail]
         klass.new(instant_fail).run
       end
     end
    end
  end
  # end
end
