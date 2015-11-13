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
      conds << "#{column} >= ?"
      vals << gt
    end

    if lt.kind_of? Fixnum
      conds << "#{column} <= ?"
      vals << lt
    end

    if conds.empty?
      scope
    else
      filter_and_or_highlight column, filter, [conds.join(' AND '), *vals]
    end
  end

  # Input: value, "or" ("and" by default)
  def self.boolean_filter(column, filter)
    val = filter[:value]

    if val.kind_of? Fixnum
      if filter[:or]
        vals = [val]
      else
        vals = []
        n = 1
        Math.log2(val).ceil.times do
          vals.push(n) if n & val > 0
          n = n << 1
        end
      end

      conditions = [vals.map{|v| "#{column} & ? > 0" }.join(' AND '), *vals]
      filter_and_or_highlight column, filter, conditions
    else
      scope
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
      # [[:<:]] begining of a word
      '[[:<:]]' + v + '.*?'
    end.join

    condition = sanitize_sql_array(["name_slug ~ ?", regex])

    filter_and_or_highlight(:name, filter, condition)
  end)

  register_filter :steam_id, :exact_filter
  register_filter :steam_price, :range_filter
  register_filter :metacritic, :range_filter
  register_filter :steam_reviews_count, :range_filter
  register_filter :steam_reviews_ratio, :range_filter

  register_filter :lowest_steam_price, :range_filter
  register_filter :steam_discount, :range_filter

  register_filter :playtime_mean, :range_filter
  register_filter :playtime_median, :range_filter
  register_filter :playtime_rsd, :range_filter
  register_filter :playtime_mean_ftb, :range_filter
  register_filter :playtime_median_ftb, :range_filter

  register_filter :features, :boolean_filter
  register_filter :players, :boolean_filter
  register_filter :controller_support, :boolean_filter

  register_simple_sort :name, :name_slug


  ### Computed attributes ###
  ###########################

  serialize :playtime_ils, JSON
  before_save :compute_values

  def compute_values
    sp = steam_price
    ssp = steam_sale_price
    self.lowest_steam_price = [sp, ssp].compact.min
    self.steam_discount = ssp ? ((1-ssp.to_f/sp)*100).round : 0

    if positive_steam_reviews and negative_steam_reviews
      steam_reviews = positive_steam_reviews + negative_steam_reviews
      if not steam_reviews.empty?
        stats = DescriptiveStatistics::Stats.new(steam_reviews)
        self.playtime_mean = stats.mean
        self.playtime_median = stats.median
        self.playtime_sd = stats.standard_deviation
        self.playtime_rsd = stats.relative_standard_deviation
        self.playtime_ils = (5..95).step(5).map{ |p| stats.value_from_percentile(p) }
        if (lowest_steam_price and lowest_steam_price != 0)
          self.playtime_mean_ftb = playtime_mean/(lowest_steam_price.to_f/100)
          self.playtime_median_ftb = playtime_median/(lowest_steam_price.to_f/100)
        end
      end
    end
  end

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
