module FilteringHelpers
  extend ActiveSupport::Concern

  class_methods do
    def register_filter(filter_name, filter_type, filter_column = nil)
      filter_column ||= filter_name

      raise "No such filter type #{filter_type}" unless respond_to? filter_type

      @@filters ||= {}
      @@filters_columns ||= {}
      @@filters[filter_name] = filter_type
      @@filters_columns[filter_name] = filter_column

      scope :"filter_by_#{filter_name}", (lambda{ |params|
        apply_filter(filter_name, params)
      })
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
      raise "No such filter #{name}" unless @@filters[name]
      params = params.symbolize_keys
      column = @@filters_columns[name]
      L column
      if ( condition = method(@@filters[name]).call(column, params) )
        filter_and_or_highlight name, params, condition
      else
        scope
      end
    end

    # Condition and name should be sanitized!
    def filter_and_or_highlight(name, params, condition)
      scope = all

      if not params[:highlight]
        scope.where(condition)
      else
        condition_str = condition.kind_of?(Array) ? sanitize_sql_array(condition) : condition

        hl_column = "#{condition_str} AS hl_#{name}"
        scope.select_values = ['games.*'] if scope.select_values.empty?
        scope.select_values += [hl_column]
        scope
      end
    end

    def available_filters
      @@filters.keys
    end
  end
end
