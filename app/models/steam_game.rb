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
#
# Indexes
#
#  index_steam_games_on_steam_id  (steam_id) UNIQUE
#

class SteamGame < Scrapers::Steam::SteamGame
  include GetForXScraping

  has_one :game

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

  after_create :create_game_with_the_same_name
  def create_game_with_the_same_name
    Game.create_from_steam_game self
  end

  after_update :send_processing_signal
  def send_processing_signal
    if game
      game.process_steam_game_data previous_changes.keys
      game.save!
    end
  end

  def self.games_with_a_broken_community_hub_that_makes_no_sense
    where('positive_reviews = ? AND negative_reviews = ?', '[]', '[]').where.not(reviews_count: 0).includes(:game)
  end
end
