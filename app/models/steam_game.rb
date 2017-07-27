# == Schema Information
#
# Table name: steam_games
#
#  id                     :integer          not null, primary key
#  steam_id               :integer          not null
#  name                   :string
#  tags                   :string           default([]), not null
#  genre                  :string
#  summary                :text
#  released_at            :datetime
#  thumbnail              :string
#  videos                 :text             default([]), not null
#  images                 :text             default([]), not null
#  price                  :integer
#  sale_price             :integer
#  reviews_ratio          :integer
#  reviews_count          :integer
#  positive_reviews_count :integer
#  negative_reviews_count :integer
#  positive_reviews       :text             default([]), not null
#  negative_reviews       :text             default([]), not null
#  dlc_count              :integer
#  achievements_count     :integer
#  audio_languages        :string           default([]), not null
#  subtitles_languages    :string           default([]), not null
#  metacritic             :integer
#  esrb_rating            :string
#  early_access           :boolean
#  system_requirements    :text
#  players                :integer          default(0), not null
#  controller_support     :integer          default(0), not null
#  features               :integer          default(0), not null
#  platforms              :integer          default(0), not null
#  vr_platforms           :integer          default(0), not null
#  vr_mode                :integer          default(0), not null
#  vr_controllers         :integer          default(0), not null
#  game_scraped_at        :datetime
#  list_scraped_at        :datetime
#  reviews_scraped_at     :datetime
#  text_release_date      :string
#  developer              :string
#  publisher              :string
#  community_hub_id       :integer
#  blacklist              :boolean          default(FALSE), not null
#  steam_published_at     :datetime
#  vr_only                :boolean          default(FALSE), not null
#
# Indexes
#
#  index_steam_games_on_steam_id  (steam_id) UNIQUE
#

class JSONWithSymbolsSerializer
  def self.load(str)
    str.nil? ? nil : JSON.parse(str, symbolize_names: true)
  end

  def self.dump(data)
    JSON.dump(data)
  end
end

class SteamGame < ActiveRecord::Base
  include GetForXScraping
  include SimpleFlaggableColumn
  include SimpleEnum

  has_one :game

  flag_column :players, {
    single_player:        0b1,
    multi_player:         0b10,
    co_op:                0b100,
    local_co_op:          0b1000,
    local_multi_player:   0b10000,
    online_multi_player:  0b100000,
    online_co_op:         0b1000000,
    shared_screen:        0b10000000,
    cross_platform_multi: 0b100000000
  }

  flag_column :features, {
    steam_achievements:  0b000001,
    steam_trading_cards: 0b000010,
    # vr_support:          0b000100,
    steam_workshop:      0b001000,
    steam_cloud:         0b010000,
    valve_anti_cheat:    0b100000
  }

  simple_enum_column :controller_support, {
    no: 1,
    partial: 2,
    full: 3
  }

  flag_column :vr_platforms, {
    vive:   0b1,
    rift:   0b10,
    osvr:   0b100
  }

  flag_column :vr_mode, {
    seated: 0b001,
    standing: 0b010,
    room_scale: 0b100
  }

  flag_column :vr_controllers, {
    tracked: 0b001,
    gamepad: 0b010,
    keyboard_mouse: 0b100
  }

  flag_column :platforms, {
    win:   0b001,
    mac:   0b010,
    linux: 0b100
  }

  serialize :tags, JSON
  serialize :audio_languages, JSON
  serialize :subtitles_languages, JSON
  serialize :videos, JSON
  serialize :images, JSON
  serialize :system_requirements, JSONWithSymbolsSerializer
  serialize :positive_reviews, JSON
  serialize :negative_reviews, JSON

  # If it was launched less than X ago,
  # then scrap it if Y time has passed since the last scraping

  get_for_x_scraping(:reviews, [
    [1.week,  1.day],
    [1.month, 1.week],
    [1.year,  1.month],
    [3.years, 3.months],
    [         1.year]
  ]){ where('reviews_count > 0').where(blacklist: false) }

  get_for_x_scraping(:game, [
    [1.week,  1.day],
    [1.month, 1.week],
    [1.year,  1.month],
    [3.years, 3.months],
    [         1.year]
  ]){ where(blacklist: false) }

  def propagate_to_game
    game = Game.find_or_build_from_name name
    game.steam_game = self
    game.compute_all
    game.save!
    game
  end

  def self.from_list_scraper!(attributes)
    JSON::Validator.validate! Scrapers::Steam::List::SCHEMA, attributes
    game = find_by_steam_id(attributes[:steam_id]) || new
    game.assign_attributes attributes
    game.list_scraped_at = Time.now
    game.save!
    game
  end

  def self.from_game_scraper!(attributes)
    JSON::Validator.validate! Scrapers::Steam::Game::SCHEMA, attributes
    game = find_by_steam_id(attributes[:steam_id])
    game.assign_attributes attributes
    game.game_scraped_at = Time.now
    game.save!
    game
  end

  def self.from_reviews_scraper!(attributes)
    JSON::Validator.validate! Scrapers::Steam::Reviews::SCHEMA, attributes
    game = find_by_steam_id(attributes[:steam_id])
    game[:positive_reviews] = attributes[:positive]
    game[:negative_reviews] = attributes[:negative]
    game.reviews_scraped_at = Time.now
    game.save!
    game
  end

  def self.update_not_on_sale(on_sale_ids)
    previously_on_sale_query = where.not(steam_id: on_sale_ids, sale_price: nil)
    previously_on_sale = previously_on_sale_query.to_a
    previously_on_sale_query.update_all(sale_price: nil)
    previously_on_sale.each{ |g| g.propagate_to_game }
  end

  def url
    "http://store.steampowered.com/app/#{steam_id}/"
  end
end
