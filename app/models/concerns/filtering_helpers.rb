module FilteringHelpers
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    def register_filter(filter_name, proc_block)
      if proc_block.kind_of? Symbol
        proc_block = method(proc_block).to_proc.curry.call(filter_name)
      end

      @@filters ||= {}
      @@filters[filter_name] = proc_block
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

    def apply_filters(filters)
      filtered = all

      if filters.kind_of? String
        filters = JSON.parse(filters)
      end

      if filters.kind_of? Hash
        filters.each_pair do |name, params|
          filtered = filtered.apply_filter(name, params)
        end
      end
      filtered
    end

    def apply_filter(name, params)
      name = name.to_sym
      if @@filters[name]
        @@filters[name].call(params.symbolize_keys)
      else
        raise "Filter #{name} doesn't"
      end
    end

    # Condition and name should be sanitized!
    def filter_and_or_highlight(name, filter, condition)
      scope = all

      if filter[:filter]
        scope = scope.where(condition)
        condition = true # Avoid running the condition again
      end

      if filter[:highlight]
        condition_str = condition.kind_of?(Array) ? sanitize_sql_array(condition) : condition

        hl_column = "#{condition_str} AS hl_#{name}"
        scope.select_values = ['games.*'] if scope.select_values.empty?
        scope.select_values += [hl_column]
      end

      scope
    end

    def available_filters
      @@filters.keys
    end
  end
end
