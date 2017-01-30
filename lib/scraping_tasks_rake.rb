require 'scraping_tasks'
require 'rake'

class ScrapingTasksRake
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
end
