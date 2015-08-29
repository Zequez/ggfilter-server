class Game < ActiveRecord::Base
  default_scope { select('games.*') }

  def self.register_filter(filter_name, proc_block)
    (@@filters ||= []) << filter_name
    scope :"filter_by_#{filter_name}", proc_block
  end

  def self.register_sort(sort_name, proc_block)
    (@sorts ||= []) << sort_name
    scope :"sort_by_#{sort_name}", proc_block
  end

  register_filter :name, (lambda do |filter|
    condition = sanitize_sql_array(['LOWER(name) = ?', filter[:value].downcase])
    filter_and_or_highlight(:name, filter, condition)
  end)

  # Condition and name should be sanitized!
  def self.filter_and_or_highlight(name, filter, condition)
    scope = all

    if filter[:filter]
      scope = scope.where(condition)
      if filter[:highlight]
        condition = '1' # Avoid running the condition again
      end
    end

    if filter[:highlight]
      hl_column = "#{condition} AS hl_#{name}"
      scope = scope.select hl_column
    end

    scope
  end
end
