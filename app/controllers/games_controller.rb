class GamesController < ApplicationController
  # def decils
  #   data = Game.multi_entil([
  #     :steam_sale_price,
  #     :steam_reviews_ratio,
  #     :playtime_mean
  #   ])
  #
  #   respond_to do |f|
  #     f.json do
  #       render json: data
  #     end
  #   end
  # end

  # def system_reqs
  #   # ana = VideoCardAnalyzer.new
  #   # @videos = Hash[Game.pluck(:steam_id, :system_requirements).map do |pair|
  #   #   min = pair[1][:minimum] && pair[1][:minimum][:video_card]
  #   #   req = pair[1][:recommended] && pair[1][:recommended][:video_card]
  #   #   min_tokens = min ? ana.tokens(min) : nil
  #   #   req_tokens = req ? ana.tokens(req) : nil
  #   #   [pair[0], {min: [min, min_tokens], req: [req, req_tokens]}]
  #   # end]
  #   render layout: false
  # end

  def show
    @game = Game.find_by_steam_id(params[:id])
    render json: @game
  end

  def index
    @games = Game
      .select(columns)
      .apply_filters(params[:filters])
      .order(allowed_sort(params[:sort]))
      .paginate(page: params[:page].to_i+1, per_page: per_page)
      .limit(20)

    games = @games.map(&:attributes)
    render json: games
  end

  def allowed_sort(sort)
    allowed_sorts = Game.available_filters
    if sort.kind_of? String
      direction = (sort =~ /_desc$/) ? 'DESC NULLS LAST' : 'ASC NULLS FIRST'
      sort = sort.sub(/(_desc|_asc)$/, '')
      return "#{sort} #{direction}" if allowed_sorts.include? sort.to_sym
    end
    'steam_id ASC'
  end

  def allowed_columns
    @allowed_columns ||= [
      'steam_id', 'name',
      'steam_price', 'steam_reviews_ratio', 'steam_sale_price', 'steam_discount', 'released_at',
      'platforms', 'tags', 'genre', 'metacritic', 'summary',
      'players', 'controller_support', 'features', 'vr',
      'steam_reviews_count', 'positive_steam_reviews_count', 'negative_steam_reviews_count',
      'playtime_mean', 'playtime_median', 'playtime_sd', 'playtime_rsd', 'playtime_ils',
      'playtime_mean_ftb', 'playtime_median_ftb',
      'steam_thumbnail', 'images', 'videos',
      'system_requirements'
    ]
  end

  def columns
    @columns ||= begin
      columns = (allowed_columns - (allowed_columns - (params[:columns] || [])))
      (columns.empty? ? allowed_columns : columns) + ['id']
    end
  end

  def per_page
    [params[:limit].to_i, 50].min
  end
end
