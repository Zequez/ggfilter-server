class Game < ActiveRecord::Base
  extend FriendlyId
  include FilteringHelpers
  include SimpleFlaggableColumn
  include GetForXScraping
  include Scrapers::SteamList::GameExtension
  include Scrapers::SteamGame::GameExtension
  include Scrapers::SteamReviews::GameExtension

  friendly_id :name, use: :slugged, slug_column: :name_slug

  default_scope { select('games.*') }

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
