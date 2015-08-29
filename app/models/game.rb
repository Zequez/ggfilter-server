class Game < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged, slug_column: :name_slug

  default_scope { select('games.*') }

  def self.register_filter(filter_name, proc_block)
    (@@filters ||= []) << filter_name
    scope :"filter_by_#{filter_name}", proc_block
  end

  def self.register_sort(sort_name, proc_block)
    (@sorts ||= []) << sort_name
    scope :"sort_by_#{sort_name}", proc_block
  end

  def self.register_simple_sort(name, column_name = nil)
    column_name ||= name
    register_sort name, (lambda do |direction|
      order "#{column_name} " + (direction == :asc ? 'ASC' : 'DESC')
    end)
  end

  register_filter :name, (lambda do |filter|
    value = filter[:value].to_s.parameterize.split('-')
    regex = value.map do |v|
      if v =~ /^\d+$/
        roman = RomanNumerals.to_roman(Integer v).downcase
        v = "(#{v}|#{roman})"
      end
      '[[:<:]]' + v + '[^-]*'
    end.join('-')
    condition = sanitize_sql_array(["name_slug ~ ?", regex])
    filter_and_or_highlight(:name, filter, condition)
  end)

  register_simple_sort :name, :name_slug

  # Condition and name should be sanitized!
  def self.filter_and_or_highlight(name, filter, condition)
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
