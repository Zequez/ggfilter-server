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
#  oculus_game_id             :integer
#  steam_price                :integer
#  steam_price_regular        :integer
#  steam_price_discount       :integer
#  oculus_price               :integer
#  oculus_price_regular       :integer
#  oculus_price_discount      :integer
#  lowest_price               :integer
#  ratings_count              :integer
#  positive_ratings_count     :integer
#  negative_ratings_count     :integer
#  ratings_ratio              :integer
#  released_at                :datetime
#  players                    :integer          default(0), not null
#  controllers                :integer          default(0), not null
#  vr_modes                   :integer          default(0), not null
#  vr_platforms               :integer          default(0), not null
#  gamepad                    :integer          default(0), not null
#  vr_only                    :boolean          default(FALSE), not null
#  platforms                  :integer          default(0), not null
#  sysreq_gpu_string          :string
#  sysreq_gpu_tokens          :string
#  sysreq_index               :integer
#  sysreq_index_pct           :integer
#
# Indexes
#
#  index_games_on_oculus_game_id  (oculus_game_id)
#  index_games_on_steam_game_id   (steam_game_id)
#
# Foreign Keys
#
#  fk_rails_00d4665526  (oculus_game_id => oculus_games.id)
#  fk_rails_11ce781341  (steam_game_id => steam_games.id)
#

class Game < ActiveRecord::Base
  extend FriendlyId
  include SimpleFlaggableColumn
  extend GameFilters

  friendly_id :name, use: :slugged, slug_column: :name_slug

  belongs_to :steam_game, optional: true
  belongs_to :oculus_game, optional: true

  ### Computed attributes ###
  ###########################

  serialize :sysreq_video_tokens_values, JSON
  serialize :tags, JSON

  ### Flag columns ###
  ####################

  flag_column :players, {
    single:         0b1,
    multi:          0b10,
    online:         0b100,
    co_op:          0b1000,
    shared:         0b10000,
    hotseat:        0b100000,
    cross_platform: 0b1000000
  }

  flag_column :controllers, {
    tracked:        0b1,
    gamepad:        0b10,
    keyboard_mouse: 0b100
  }

  flag_column :vr_platforms, {
    vive: 0b1,
    rift: 0b10,
    osvr: 0b100
  }

  flag_column :vr_modes, {
    seated:     0b1,
    standing:   0b10,
    room_scale: 0b100
  }

  flag_column :platforms, {
    win:   0b1,
    mac:   0b10,
    linux: 0b100
  }

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

  def self.find_or_build_from_name(name)
    where(name_slug: name.to_s.parameterize).first || new(name: name)
  end

  # We need to compute this globally because
  # to compute the token values we need to have
  # all the known tokens for inferrence
  def self.mass_compute_sysreq_index
    # We might add other tokens in the future

    ids, tokens =
      where.not(sysreq_gpu_tokens: nil)
      .pluck(:id, :sysreq_gpu_tokens)
      .transpose

    tokens = tokens.map{ |tokens_string| tokens_string.split(' ') }

    known_tokens = Gpu.get_tokens_hash
    sysana = SysreqAnalyzer.new tokens, known_tokens

    values = sysana.get_list_values_averages

    update_all_for_each ids, sysreq_index: values
  end

  def self.compute_percentiles
    compute_percentile_for :sysreq_index, :sysreq_index_pct
  end

  def self.compute_percentile_for(column, target_column)
    ids, values = where.not(column => nil).pluck(:id, column).transpose
    stats = DescriptiveStatistics::Stats.new(values)
    values_pct = values.map{ |value| stats.percentile_rank value }
    update_all_for_each(ids, target_column => values_pct)
  end

  def self.update_all_for_each(ids, attributes)
    attributes.each_pair do |column, values|
      values.each_with_index do |value, i|
        where(id: ids[i]).update_all(column => value)
      end
    end
  end

  def compute_all
    compute_prices
    compute_ratings
    compute_released_at
    compute_flags
    compute_playtime_stats
    compute_tags
    compute_sysreq_string
    compute_sysreq_tokens
  end

  def compute_flags
    compute_platforms
    compute_controllers
    compute_vr_platforms
    compute_vr_modes
    compute_players
  end

  def compute_prices
    if steam_game && steam_game.price
      self.steam_price = steam_game.sale_price || steam_game.price
      self.steam_price_regular = steam_game.price
      self.steam_price_discount = _discount(steam_price, steam_price_regular)
    end

    if oculus_game
      self.oculus_price = oculus_game.price
      self.oculus_price_regular = oculus_game.price_regular || oculus_game.price
      self.oculus_price_discount = _discount(oculus_price, oculus_price_regular)
    end

    self.lowest_price = [steam_price, oculus_price].compact.min
  end

  def _discount(price, price_regular)
    ((price_regular - price).to_f / price_regular * 100).to_i
  end

  def compute_ratings
    positive = 0
    negative = 0

    if steam_game && steam_game.positive_reviews_count
      positive += steam_game.positive_reviews_count
      negative += steam_game.negative_reviews_count
    end

    if oculus_game
      oculus_positive, oculus_negative =
        _star_to_positive_negative(oculus_game.ratings)

      positive += oculus_positive
      negative += oculus_negative
    end

    self.positive_ratings_count = positive
    self.negative_ratings_count = negative
  end

  def _star_to_positive_negative(stars)
    count = stars.reduce(:+)
    total = 0
    stars.each_with_index{ |s, i| total += s * (i + 1) }

    ratio = (total.to_f / count).to_f / stars.size
    positive = (count * ratio).floor
    negative = count - positive
    [positive, negative]
  end

  def compute_released_at
    source_game = steam_game || oculus_game
    if source_game
      self.released_at = source_game.released_at
    end
  end

  def compute_platforms
    platforms = []

    if steam_game
      platforms = steam_game.platforms
    end

    if oculus_game
      platforms << :win
    end

    self.platforms = platforms
  end

  def compute_controllers
    controllers = []

    if steam_game
      self.gamepad = steam_game.controller_support
      controllers += steam_game.vr_controllers
      controllers.push :gamepad if steam_game.controller_support != :no
      controllers.push :keyboard_mouse if steam_game.vr_platforms.empty?
    end

    if oculus_game
      controllers += _flag_map(oculus_game.vr_controllers, {
        tracked: 'OCULUS_TOUCH',
        gamepad: 'GAMEPAD',
        keyboard_mouse: 'KEYBOARD_MOUSE'
      })
      self.gamepad = :full if controllers.include?(:gamepad) && !self.gamepad
    end

    self.controllers = controllers
  end

  def compute_vr_platforms
    vr_platforms = []

    if steam_game
      vr_platforms = steam_game.vr_platforms
    end

    if oculus_game
      vr_platforms.push :rift
    end

    self.vr_platforms = vr_platforms
  end

  def compute_vr_modes
    vr_modes = []

    if steam_game
      vr_modes += steam_game.vr_mode
    end

    if oculus_game
      vr_modes += _flag_map(oculus_game.vr_mode, {
        seated: 'SITTING',
        standing: 'STANDING',
        room_scale: 'ROOM_SCALE'
      })
    end

    self.vr_modes = vr_modes
  end

  def compute_players
    players = []

    if steam_game
      players += _flag_map(steam_game.players, {
        single: [:single_player],
        multi: [
          :multi_player,
          :online_multi_player,
          :local_multi_player,
          :co_op,
          :online_co_op,
          :local_co_op,
          :shared_screen,
          :cross_platform_multi
        ],
        online: [:online_multi_player, :online_co_op],
        co_op: [:co_op, :online_co_op, :local_co_op],
        shared: [:local_co_op, :shared_screen],
        cross_platform: [:multi, :cross_platform_multi]
      })
    end

    if oculus_game
      players += _flag_map(oculus_game.players, {
        multi: ['MULTI_USER', 'CO_OP'],
        single: ['SINGLE_USER'],
        co_op: ['CO_OP']
      })
    end

    self.players = players
  end

  def _flag_map(source_flags, hash)
    result = []
    hash.each_pair do |target, origin|
      origin = Array(origin)
      result.push target if (origin - source_flags).size < origin.size
    end
    result
  end

  def compute_playtime_stats
    # requires compute_prices
    if steam_game && steam_game.positive_reviews && steam_game.negative_reviews
      steam_reviews = steam_game.positive_reviews + steam_game.negative_reviews

      if not steam_reviews.empty?
        stats = DescriptiveStatistics::Stats.new(steam_reviews)
        self.playtime_mean = stats.mean
        self.playtime_median = stats.median
        self.playtime_sd = stats.standard_deviation
        self.playtime_rsd = stats.standard_deviation / stats.mean * 100
        if lowest_price && lowest_price != 0
          self.playtime_mean_ftb = playtime_mean/(lowest_price.to_f/100)
          self.playtime_median_ftb = playtime_median/(lowest_price.to_f/100)
        end
      end
    end
  end

  def compute_tags
    tags_groups = []

    if steam_game
      tags_groups.push steam_game.tags
    end

    if oculus_game
      tags_groups.push oculus_game.genres
    end

    if tags_groups.size > 0
      self.tags = Array.new(tags_groups.map(&:size).max)
        .zip(*tags_groups)
        .flatten
        .compact
    end
  end

  def compute_sysreq_string
    strings = []

    if steam_game && steam_game.system_requirements
      sr = steam_game.system_requirements
      if sr[:minimum] && sr[:minimum][:video_card]
        strings.push sr[:minimum][:video_card]
      end

      if sr[:recommended] && sr[:recommended][:video_card]
        strings.push sr[:recommended][:video_card]
      end
    end

    if oculus_game && oculus_game.sysreq_gpu
      strings.push oculus_game.sysreq_gpu
    end

    self.sysreq_gpu_string = strings.join(' | ')
  end

  def compute_sysreq_tokens
    # requires compute_released_at

    if sysreq_gpu_string
      ana = VideoCardAnalyzer.new
      tokens = sysreq_gpu_string
        .split('|')
        .map{ |str| ana.tokens str }
        .flatten
        .uniq

      tokens.push "year#{released_at.year}" if released_at

      # These tokens naked don't really tell us anything
      tokens -= ['nvidia', 'amd', 'intel']

      self.sysreq_gpu_tokens = tokens.join(' ')
    end
  end

  def self.compute_sysreq_index

  end

  ### Tags ###
  ############

  def tags=(value)
    super value.map{|v|
      if v.kind_of? String
        Tag.find_or_create_by_name(v).id
      elsif v.kind_of? Fixnum
        v
      else
        nil
      end
    }.compact.uniq
  end

  ### Utils ###
  #############

  def gamepad_enum
    { no: 1, partial: 2, full: 3 }
  end

  def gamepad=(support)
    write_attribute :gamepad, gamepad_enum[support.to_sym]
  end

  def gamepad
    gamepad_enum.invert[read_attribute :gamepad]
  end
end
