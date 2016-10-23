# == Schema Information
#
# Table name: games
#
#  id                           :integer          not null, primary key
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  name                         :string
#  steam_name                   :string
#  steam_id                     :integer
#  steam_price                  :integer
#  steam_sale_price             :integer
#  steam_reviews_ratio          :integer
#  steam_reviews_count          :integer
#  steam_thumbnail              :string
#  released_at                  :datetime
#  steam_list_scraped_at        :datetime
#  platforms                    :integer          default(0), not null
#  name_slug                    :string
#  tags                         :string
#  genre                        :string
#  dlc_count                    :integer
#  steam_achievements_count     :integer
#  audio_languages              :string
#  subtitles_languages          :string
#  metacritic                   :integer
#  esrb_rating                  :string
#  videos                       :text
#  images                       :text
#  summary                      :text
#  early_access                 :boolean
#  system_requirements          :text
#  players                      :integer
#  controller_support           :integer
#  features                     :integer
#  positive_steam_reviews_count :integer
#  negative_steam_reviews_count :integer
#  steam_game_scraped_at        :datetime
#  positive_steam_reviews       :text
#  negative_steam_reviews       :text
#  steam_reviews_scraped_at     :datetime
#  lowest_steam_price           :integer
#  steam_discount               :integer
#  playtime_mean                :float
#  playtime_median              :float
#  playtime_sd                  :float
#  playtime_rsd                 :float
#  playtime_ils                 :string
#  playtime_mean_ftb            :float
#  playtime_median_ftb          :float
#  vr                           :integer          default(0), not null
#  sysreq_video_tokens          :string           default(""), not null
#  sysreq_video_index           :integer
#  sysreq_index_centile         :integer

class Game < ActiveRecord::Base
  extend FriendlyId
  include GameFilters
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

  register_filter :name,                 :name_filter
  register_filter :tags,                 :tags_filter
  register_filter :steam_id,             :exact_filter
  register_filter :steam_price,          :range_filter
  register_filter :metacritic,           :range_filter
  register_filter :steam_reviews_count,  :range_filter
  register_filter :steam_reviews_ratio,  :range_filter
  register_filter :released_at,          :relative_date_filter
  register_filter :released_at_absolute, :range_filter, :released_at

  register_filter :lowest_steam_price,   :range_filter
  register_filter :steam_discount,       :range_filter

  register_filter :playtime_mean,        :range_filter
  register_filter :playtime_median,      :range_filter
  register_filter :playtime_rsd,         :range_filter
  register_filter :playtime_mean_ftb,    :range_filter
  register_filter :playtime_median_ftb,  :range_filter

  register_filter :controller_support,   :range_filter
  register_filter :platforms,            :boolean_filter
  register_filter :features,             :boolean_filter
  register_filter :players,              :boolean_filter
  register_filter :vr,                   :boolean_filter

  register_filter :sysreq_video_index,   :range_filter
  register_filter :sysreq_index_centile, :range_filter
  # register_filter :system_requirements,  :system_requirements_filter

  ### Computed attributes ###
  ###########################

  serialize :playtime_ils, JSON
  before_save :compute_values

  def compute_values(force = false)
    if (
      steam_price_changed? ||
      steam_sale_price_changed? ||
      positive_steam_reviews_changed? ||
      negative_steam_reviews_changed? ||
      force
    )
      compute_playtime_stats
    end

    if system_requirements_changed? || force
      compute_sysreq_tokens
      compute_sysreq_video_index
    end
  end

  def compute_playtime_stats
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

  def compute_sysreq_tokens
    tokens = []
    ana = VideoCardAnalyzer.new
    sysreq = system_requirements
    if sysreq
      if sysreq[:minimum] && sysreq[:minimum][:video_card]
        tokens.concat ana.tokens sysreq[:minimum][:video_card]
      end
      if sysreq[:recommended] && sysreq[:recommended][:video_card]
        tokens.concat ana.tokens sysreq[:recommended][:video_card]
      end
    end

    tokens.push "year#{released_at.year}" if released_at

    self.sysreq_video_tokens = tokens.uniq.join(' ')
  end

  def compute_sysreq_video_index
    heavier = /nvidia|amd|intel|mb/
    tokens = SysreqToken.where(name: sysreq_video_tokens.split(' ')).where.not(value: nil)
    if tokens.size > 0
      values = []
      tokens.each do |t|
        values << t.value
        if t.name =~ heavier
          values << t.value
        end
      end
      self.sysreq_video_index = (values.reduce(&:+).to_f / values.size).round
    end
  end

  def self.compute_sysreq_index_centiles
    id_indexes = Game.where.not(sysreq_video_index: nil).pluck(:id, :sysreq_video_index)
    indexes = id_indexes.map{ |a| a[1] }
    stats = DescriptiveStatistics::Stats.new(indexes)
    id_indexes.each do |a|
      percentile = stats.percentile_from_value a[1]
      Game.where(id: a[0]).update_all(sysreq_index_centile: percentile)
    end
  end

  ### Tags ###
  ############

  def tags=(value)
    super value.map{|v|
      if v.kind_of? String
        Tag.find_or_create_by(name: v).id
      elsif v.kind_of? Fixnum
        v
      else
        nil
      end
    }.compact
  end


  ### Utils ###
  #############

  def sysreq_video
    texts = []
    s = system_requirements
    if s[:minimum] && s[:minimum][:video_card]
      texts.push s[:minimum][:video_card]
    end
    if s[:recommended] && s[:recommended][:video_card]
      texts.push s[:recommended][:video_card]
    end
    texts.join('|||')
  end

  def steam_url
    "http://store.steampowered.com/app/#{steam_id}/"
  end

  def sysreq(type, value)
    type = :minimum if type == :min
    type = :recommended if type == :rec
    value = :video_card if value == :gpu
    value = :processor if value == :cpu
    value = :memory if value == :ram
    value = :hard_drive if value == :hdd
    system_requirements[type] && system_requirements[type][value]
  end

  def self.entil(column, il = 10)
    values = (column.kind_of?(Array) ? column : all.pluck(column)).compact#.reject(&:nan?)
    stats = DescriptiveStatistics::Stats.new(values)
    return [stats.median] if il == 2
    return (0..99).step(100/il).to_a[1..-1].map{ |p| stats.value_from_percentile(p) }
  end

  def self.multi_entil(columns, il = 10)
    values = all.pluck(*columns)
    result = columns.each_with_index.map do |column, i|
      [column, entil(values.map{|v| v[i]})]
    end
    Hash[result]
  end
end
