# == Schema Information
#
# Table name: steam_games
#
#  id                     :integer          not null, primary key
#  steam_id               :integer          not null
#  name                   :string
#  tags                   :string
#  genre                  :string
#  summary                :text
#  released_at            :datetime
#  thumbnail              :string
#  videos                 :text
#  images                 :text
#  price                  :integer
#  sale_price             :integer
#  reviews_ratio          :integer
#  reviews_count          :integer
#  positive_reviews_count :integer
#  negative_reviews_count :integer
#  positive_reviews       :text
#  negative_reviews       :text
#  dlc_count              :integer
#  achievements_count     :integer
#  audio_languages        :string
#  subtitles_languages    :string
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
#

class SteamGame < Scrapers::Steam::SteamGame
  include GetForXScraping

  has_one :game

  # If it was launched less than X ago,
  # then scrap it if Y time has passed since the last scraping

  get_for_x_scraping :reviews, [
    [1.week,  1.day],
    [1.month, 1.week],
    [1.year,  1.month],
    [3.years, 3.months],
    [         1.year]
  ]

  get_for_x_scraping :game, [
    [1.week,  1.day],
    [1.month, 1.week],
    [1.year,  1.month],
    [3.years, 3.months],
    [         1.year]
  ]
end