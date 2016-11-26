# == Schema Information
#
# Table name: games
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  name                       :string
#  name_slug                  :string
#  playtime_mean              :float
#  playtime_median            :float
#  playtime_sd                :float
#  playtime_rsd               :float
#  playtime_ils               :string
#  playtime_mean_ftb          :float
#  playtime_median_ftb        :float
#  sysreq_video_tokens        :string           default(""), not null
#  sysreq_video_index         :integer
#  sysreq_index_centile       :integer
#  steam_game_id              :integer
#  lowest_steam_price         :integer
#  steam_discount             :integer
#  tags                       :string           default([]), not null
#  sysreq_video_tokens_values :text
#
# Indexes
#
#  index_games_on_steam_game_id  (steam_game_id)
#
# Foreign Keys
#
#  fk_rails_11ce781341  (steam_game_id => steam_games.id)
#

class Game < ActiveRecord::Base
  extend FriendlyId
  include FilteringHelpers
  include GameFilters

  friendly_id :slug_candidates, use: :slugged, slug_column: :name_slug

  def slug_candidates
    [
      :name
    ]
  end

  belongs_to :steam_game, optional: true

  ### Filters ###
  ###############

  register_filter :name, :name_filter
  register_filter :tags, :tags_filter
  register_filter :steam_id, :exact_filter, column: [:steam_game, :steam_id]
  register_filter :steam_price, :range_filter, column: [:steam_game, :price]
  register_filter :metacritic, :range_filter, column: [:steam_game, :metacritic]
  register_filter :steam_reviews_count, :range_filter, column: [:steam_game, :reviews_count]
  register_filter :steam_reviews_ratio, :range_filter, column: [:steam_game, :reviews_ratio]
  register_filter :released_at, :relative_date_range_filter, column: [:steam_game, :released_at]
  register_filter :released_at_absolute, :date_range_filter,
    column: [:steam_game, :released_at],
    as: :released_at
  register_filter :lowest_steam_price, :range_filter,
    joins: :steam_game,
    select: [:lowest_steam_price, 'steam_games.price AS steam_price']
  register_filter :steam_discount, :range_filter

  register_filter :playtime_mean, :range_filter
  register_filter :playtime_median, :range_filter
  register_filter :playtime_rsd, :range_filter
  register_filter :playtime_mean_ftb, :range_filter
  register_filter :playtime_median_ftb, :range_filter

  register_filter :controller_support, :range_filter, column: [:steam_game, :controller_support]
  register_filter :platforms, :boolean_filter, column: [:steam_game, :platforms]
  register_filter :features, :boolean_filter, column: [:steam_game, :features]
  register_filter :players, :boolean_filter, column: [:steam_game, :players]
  register_filter :vr_platforms, :boolean_filter, column: [:steam_game, :vr_platforms]
  register_filter :vr_mode, :boolean_filter, column: [:steam_game, :vr_mode]
  register_filter :vr_controllers, :boolean_filter, column: [:steam_game, :vr_controllers]

  register_filter :sysreq_video_index, :range_filter
  register_filter :sysreq_index_centile, :range_filter
  # # register_filter :system_requirements,  :system_requirements_filter

  register_column :images, column: [:steam_game, :images]
  register_column :videos, column: [:steam_game, :videos]
  register_column :steam_thumbnail, column: [:steam_game, :thumbnail]
  register_column :sysreq_video_tokens_values

  ### Computed attributes ###
  ###########################

  serialize :sysreq_video_tokens_values, JSON
  serialize :playtime_ils, JSON
  serialize :tags, JSON

  # These are from steam_game but we need them here too so it deserialize them
  # attr_accessor :images
  # attr_accessor :videos
  # serialize :images, JSON
  # serialize :videos, JSON
  # attribute :images
  # attribute :videos

  def attributes
    attrs = super
    attrs['images'] = JSON.load(attrs['images']) if attrs['images'].kind_of? String
    attrs['videos'] = JSON.load(attrs['videos']) if attrs['videos'].kind_of? String
    attrs
  end

  def self.create_from_steam_game(steam_game, extra_attributes = {})
    game = find_by_name(steam_game.name)
    if !game || (game.steam_game_id && game.steam_game_id != steam_game.id)
      attrs = {name: steam_game.name, steam_game: steam_game}.merge(extra_attributes)
      game = create(attrs)
      game.process_steam_game_data
      game.save!
    elsif !game.steam_game_id
      game.steam_game = steam_game
      game.process_steam_game_data
      game.save!
    else
      raise 'This really should not happen'
    end
  end

  def self.process_steam_game_data
    Game
      .all
      .in_batches
      .each_record do |game|
        game.process_steam_game_data
        game.save!
      end
    nil
  end

  def self.digest_system_requirements
    Game
      .all
      .in_batches
      .each_record do |game|
        game.compute_sysreq_tokens
        game.save!
      end
    nil
  end

  def process_steam_game_data(changed_attributes = nil)
    ca = changed_attributes

    self.compute_simple_steam_values

    if !ca || ca.include?('tags')
      self.compute_steam_game_tags
    end

    if (
      !ca ||
      ca.include?('price') ||
      ca.include?('sale_price') ||
      ca.include?('positive_reviews') ||
      ca.include?('negative_reviews')
    )
      self.compute_playtime_stats
    end

    if !ca || ca.include?('system_requirements')
      self.compute_sysreq_tokens
    end
  end

  def compute_simple_steam_values
    sp = steam_game.price
    ssp = steam_game.sale_price
    self.lowest_steam_price = [sp, ssp].compact.min
    self.steam_discount = ssp ? ((1-ssp.to_f/sp)*100).round : 0
  end

  def compute_steam_game_tags
    if steam_game.tags && !steam_game.tags.empty?
      self.tags = steam_game.tags
    end
  end

  def compute_playtime_stats
    if steam_game.positive_reviews and steam_game.negative_reviews
      steam_reviews = steam_game.positive_reviews + steam_game.negative_reviews
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
    sysreq = steam_game.system_requirements
    if sysreq
      if sysreq[:minimum] && sysreq[:minimum][:video_card]
        tokens.concat ana.tokens sysreq[:minimum][:video_card]
      end
      if sysreq[:recommended] && sysreq[:recommended][:video_card]
        tokens.concat ana.tokens sysreq[:recommended][:video_card]
      end
    end

    tokens.push "year#{steam_game.released_at.year}" if steam_game.released_at

    # These tokens naked don't really tell us anything
    tokens -= ['nvidia', 'amd', 'intel']

    self.sysreq_video_tokens = tokens.uniq.join(' ')
  end

  def compute_sysreq_video_index
    # heavier = /nvidia|amd|intel|mb/
    tokens = SysreqToken
      .where(name: sysreq_video_tokens.split(' '))
      .where.not(value: nil)
      .order('value DESC')

    if tokens.size > 0
      values = []
      tokens.each do |t|
        values << t.value
        # if t.name =~ heavier
        #   values << t.value
        # end
      end

      self.sysreq_video_tokens_values = tokens.inject({}){|h, t| h[t.name] = t.value; h}
      self.sysreq_video_index = (values.reduce(&:+).to_f / values.size).round
    end
  end

  def self.compute_sysreq_index_centiles
    Game.find_in_batches(batch_size: 250).with_index do |games, i|
      puts "Compute sysreq video index batch #{i}"
      games.each do |game|
        game.compute_sysreq_video_index
        game.save!
      end
    end

    puts 'Compute sysreq index centiles'

    id_indexes = Game.where.not(sysreq_video_index: nil).pluck(:id, :sysreq_video_index)
    indexes = id_indexes.map{ |a| a[1] }
    stats = DescriptiveStatistics::Stats.new(indexes)
    id_indexes.each do |a|
      percentile = stats.percentile_from_value a[1]
      Game.where(id: a[0]).update_all(sysreq_index_centile: percentile)
    end

    nil
  end

  def self.findsid(steam_id)
    SteamGame.find_by_steam_id(steam_id).game
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
