module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def register_filter(name, type, options = {})
      @@filters ||= {}

      options = {
        name: name,
        type: type,
        column: name,
        select: nil,
        as: nil,
        joins: nil
      }.merge(options)

      options[:joins] = Array(options[:joins])
      if options[:column].kind_of? Array
        options[:joins].push(options[:column][0])
        association_table = reflections[options[:column][0].to_s].table_name
        options[:column] = "#{association_table}.#{options[:column][1]}"
        options[:as] ||= options[:name]
      else
        options[:column] = "#{table_name}.#{options[:column]}"
      end

      options[:select] = Array(options[:select])
      options[:select].push("#{options[:column]} as #{options[:as]}") if options[:as]
      options[:select].push(options[:column]) if options[:select].empty?

      @@filters[name] = options

      if options[:type]
        scope :"filter_by_#{name}", (lambda{ |params|
          apply_filter(name, params)
        })
      end
    end

    def register_column(column, options = {})
      register_filter(column, nil, options)
    end

    def sort_by_filter(sort)
      name = sort[:filter]
      if name && @@filters[name.to_sym]
        name = name.to_sym
        direction = sort[:asc] ? 'ASC NULLS FIRST' : 'DESC NULLS LAST'
        all.joins_filter_tables(name).order("#{@@filters[name][:column]} #{direction}")
      else
        sort_by_filter({filter: :steam_id, asc: true})
      end
    end

    def apply_filters(filters)
      filtered = all

      initialize_selected(filtered)

      filters.each_pair do |name, params|
        if @@filters[name.to_sym] && params
          filtered = filtered.apply_filter(name, params)
        end
      end

      filtered
    end

    def apply_filter(name, params)
      filter = @@filters[name.to_sym]
      raise "No such filter #{name}" unless filter

      scope = all.joins_filter_tables(filter[:name])

      initialize_selected(scope)
      scope.select_values += filter[:select]

      if params.kind_of?(Hash) && filter[:type]
        params = params.symbolize_keys
        condition = method(filter[:type]).call(filter[:column], params)
        if (condition)
          if params[:hl]
            condition_str = condition.kind_of?(Array) ? sanitize_sql_array(condition) : condition

            hl_column = "#{condition_str} AS hl_#{filter[:name]}"

            scope.select_values += [hl_column]
            scope
          else
            scope.where(condition)
          end
        else
          scope
        end
      else
        scope
      end
    end

    def joins_filter_tables(name)
      scope = all
      filter = @@filters[name]
      filter[:joins].each do |j|
        scope = scope.left_outer_joins(j) unless scope.left_outer_joins_values.include?(j)
      end
      scope
    end

    def initialize_selected(scope)
      scope.select_values = ['games.id'] if scope.select_values.empty?
    end

    def available_filters
      @@filters.keys
    end
  end
end
