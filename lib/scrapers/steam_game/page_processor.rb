# Output
# Object of
#  :tags
#  :genre
#  :dlc_count
#  :steam_achievements_count
#  :curators_count
#  :audio_languages
#  :subtitles_languages
#  :metacritic
#  :esrb_rating
#  :videos
#  :pictures
#  :summary
#  :early_access
#  :system_requirements
#    :minimum
#      :processor
#      :memory
#      :graphics
#      :hard_drive
#    :recommended
#      :processor
#      :memory
#      :graphics
#      :hard_drive
#  :players
#    :single_player
#    :multi_player
#    :co_op
#    :local_co_op
#  :controller_support
#    :partial
#    :full
#  :features
#    :steam_achievements
#    :steam_trading_cards
#    :captions
#    :vr_support
#    :steam_workshop
#    :steam_cloud
#    :valve_anti_cheat
#    :source_sdk

class Scrapers::SteamGame::PageProcessor < Scrapers::BasePageProcessor
  regexp %r{http://store.steampowered.com/app/(\d+)}
end
