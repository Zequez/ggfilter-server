class PercentilesController < ApplicationController
  def index
    games = Game.pluck(:sysreq_index, :ratings_count, :ratings_ratio, :playtime_median, :playtime_sd, :playtime_median_ftb)
    ratings = games.select{ |g| g[2] && g[2] != 100 && g[2] != 0 }
    playtimes = ratings.select{ |g| g[3] }

    sysreq_index = get_percentiles games.map{ |g| g[0] }.compact
    ratings_count = get_percentiles ratings.map{ |g| g[1] }
    ratings_ratio = get_percentiles ratings.map{ |g| g[2] }
    playtime_median = get_percentiles playtimes.map{ |g| g[3] }
    playtime_sd = get_percentiles playtimes.map{ |g| g[4] }
    playtime_median_ftb = get_percentiles playtimes.map{ |g| g[5] }.compact

    render json: {
      sysreq_index: sysreq_index,
      ratings_count: ratings_count,
      ratings_ratio: ratings_ratio.map{|r| r.round(2)},
      playtime_median: playtime_median.map{|r| r.round(1)},
      playtime_sd: playtime_sd.map{|r| r.round(1)},
      playtime_median_ftb: playtime_median_ftb.map{|r| r.round(2)},
    }
  end

  private

  def get_percentiles(values)
    vals = values.sort
    size = values.size

    centile = size.to_f / 100

    100.times.map do |n|
      vals[(n * centile).round]
    end
  end
end
