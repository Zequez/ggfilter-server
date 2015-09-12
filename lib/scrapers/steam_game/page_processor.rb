# Output
# Object of
#  :tags
#  :genre
#  :dlc_count
#  :steam_achievements_count
#  :audio_languages
#  :subtitles_languages
#  :metacritic
#  :esrb_rating
#  :videos
#  :images
#  :summary
#  :early_access
#  :system_requirements
#    :minimum
#      :processor
#      :memory
#      :video_card
#      :disk_space
#    :recommended
#      :processor
#      :memory
#      :video_card
#      :disk_space
#  :players
#    :single_player
#    :multi_player
#    :co_op
#    :local_co_op
#  :controller_support
#    :no
#    :partial
#    :full
#  :features
#    :steam_achievements
#    :steam_trading_cards
#    :vr_support
#    :steam_workshop
#    :steam_cloud
#    :valve_anti_cheat

class Scrapers::SteamGame::PageProcessor < Scrapers::BasePageProcessor
  regexp %r{http://store.steampowered.com/app/(\d+)}

  def process_page
    game = {}

    game[:tags] = css('.popular_tags a').map{ |a| a.text.strip }
    game[:genre] = css('.details_block b + a[href*="genre"]').text
    game[:dlc_count] = css('.game_area_dlc_name').size
    game[:steam_achievements_count] = if ( sac = css('#achievement_block .block_title').first )
      Integer(sac.text.scan(/\d+/).flatten.first)
    else 0 end
    game[:metacritic] = (m = css('#game_area_metascore span').first) ? Integer(m.text) : nil
    game[:esrb_rating] = if ( esrb = css('img[src*="images/ratings/esrb"]').first )
      esrb['src'].scan(/esrb_(\w+)/).flatten.first.to_sym
    else nil end
    game[:early_access] = false
    game[:audio_languages], game[:subtitles_languages] = read_languages
    game[:videos] = read_videos
    game[:images] = css('.highlight_strip_screenshot img').map{ |i| i['src'].sub(/.\d+x\d+\.jpg/, '.jpg') }
    game[:summary] = css('.game_description_snippet').text.strip

    game[:players] = detect_features(
      1 => :multi_player,
      2 => :single_player,
      9 => :co_op
    )
    game[:controller_support] = detect_features(
      28 => :full,
      18 => :partial
    )
    game[:features] = detect_features(
      22 => :steam_achievements,
      29 => :steam_trading_cards,
      31 => :vr,
      30 => :steam_workshop,
      23 => :steam_cloud,
      8  => :valve_anti_cheat
    )

    game[:system_requirements] = read_system_requirements

    game
  end

  def read_videos
    css('.highlight_movie script').map do |script|
      script.text.scan(%r{http://[^"]+movie\d+\.webm\?t=\d+}).first
    end
  end

  def read_languages
    langs_names = css('.game_language_options td:nth-child(1)').map{ |td| td.text.strip }
    audio_langs = css('.game_language_options td:nth-child(3)').map{ |td| !td.element_children.empty? }
    subs_langs = css('.game_language_options td:nth-child(4)').map{ |td| !td.element_children.empty? }
    [audio_langs, subs_langs].map do |arr|
      arr.each_with_index.map{|k, i| k ? langs_names[i] : nil }.compact
    end
  end

  def read_system_requirements
    win = css('.sysreq_content[data-os="win"]')
    min = list_to_hash win.search('.game_area_sys_req_leftCol li, .game_area_sys_req_full li')
    req = list_to_hash win.search('.game_area_sys_req_rightCol li')
    {
      minimum: system_requirements_keyification(min),
      recommended: system_requirements_keyification(req)
    }
  end

  def list_to_hash(lis)
    Hash[lis.map{ |li| li.to_s.scan(/strong>([^<:]+):?<\/strong>([^<\r]+)/).flatten.map(&:strip) }]
  end

  def system_requirements_keyification(hash)
    keys = {
      processor: ['Processor'],
      memory: ['Memory'],
      video_card: ['Video Card', 'Graphics'],
      disk_space: ['Hard Disk Space', 'Hard Drive']
    }

    Hash[keys.map do |k, vals|
      val = vals.detect{|v| hash[v] }
      [k, hash[val]]
    end]
  end

  def features
    @features ||= css('.game_area_details_specs .icon a').map{ |a| Integer(a['href'].scan(/category2=(\d+)/).flatten.first) }
  end

  def detect_features(list)
    result = []
    list.each_pair do |key, value|
      result.push value if features.include?(key)
    end
    result
  end
end
