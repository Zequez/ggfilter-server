module FilteringHelpers
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    def register_filter(filter_name, proc_block)
      (@@filters ||= []) << filter_name
      scope :"filter_by_#{filter_name}", proc_block
    end

    def register_sort(sort_name, proc_block)
      (@sorts ||= []) << sort_name
      scope :"sort_by_#{sort_name}", proc_block
    end

    def register_simple_sort(name, column_name = nil)
      column_name ||= name
      register_sort name, (lambda do |direction|
        order "#{column_name} " + (direction == :asc ? 'ASC' : 'DESC')
      end)
    end

    # Condition and name should be sanitized!
    def filter_and_or_highlight(name, filter, condition)
      scope = all

      if filter[:filter]
        scope = scope.where(condition)
        condition = true # Avoid running the condition again
      end

      if filter[:highlight]
        hl_column = "#{condition} AS hl_#{name}"
        scope = scope.select hl_column
      end

      scope
    end
  end
end
