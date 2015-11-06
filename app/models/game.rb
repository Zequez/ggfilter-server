class Game < ActiveRecord::Base
  extend FriendlyId
  include FilteringHelpers
  include SimpleFlaggableColumn
  include GetForXScraping
  include Scrapers::SteamList::GameExtension
  include Scrapers::SteamGame::GameExtension
  include Scrapers::SteamReviews::GameExtension

  friendly_id :name, use: :slugged, slug_column: :name_slug

  ### Scraping time selectors ###
  ###############################

  # If it was launched less than X ago,
  # then scrap it if Y time has passed since the last scraping

  get_for_x_scraping :steam_reviews, [
    [1.week,  1.day],
    [1.month, 1.week],
    [1.year,  1.month],
    [3.years, 3.months],
    [         1.year]
  ]

  get_for_x_scraping :steam_game, [
    [1.week,  1.day],
    [1.month, 1.week],
    [1.year,  1.month],
    [3.years, 3.months],
    [         1.year]
  ]

  ### Filters ###
  ###############

  # Input: value
  def self.exact_filter(column, filter)
    filter_and_or_highlight(:steam_id, filter, ["#{column} = ?",filter[:value]])
  end

  # Input: gt, lt
  def self.range_filter(column, filter)
    vals = []
    conds = []
    gt = filter[:gt]
    lt = filter[:lt]

    if gt.kind_of? Fixnum
      conds << "#{column} > ?"
      vals << gt
    end

    if lt.kind_of? Fixnum
      conds << "#{column} < ?"
      vals << lt
    end

    if conds.empty?
      scope
    else
      filter_and_or_highlight column, filter, [conds.join(' AND '), *vals]
    end
  end

  # Input: value
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

  register_filter :steam_id, :exact_filter
  register_filter :steam_price, :range_filter
  register_filter :metacritic, :range_filter
  register_filter :steam_reviews_count, :range_filter

  register_simple_sort :name, :name_slug

  ### Utils ###
  #############

  def self.entil(column, il = 10)
    values = all.order(column).pluck(column)
    il_size = (values.size+1).to_f/il
    (il-1).times.map do |i|
      n = (il_size*(i+1))-1
      r = n-n.floor
      n = n.floor
      if r == 0
        values[n]
      else
        (values[n]+values[n+1]).to_f/2
      end
    end
  end
end
