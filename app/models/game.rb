class Game < ActiveRecord::Base
  extend FriendlyId
  include FilteringHelpers

  friendly_id :name, use: :slugged, slug_column: :name_slug

  default_scope { select('games.*') }

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
end
