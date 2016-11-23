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

  def filter
    @filter ||= begin
      ActiveSupport::HashWithIndifferentAccess.new JSON.parse(params.required(:filter))
    rescue JSON::ParserError
      {}
    end
  end

  def index
    @games = Game
      .apply_filters(filter[:params] || {})
      .sort_by_filter(filter[:sort] || {})
      .page(params[:page].to_i+1).per(per_page)
      .limit(20)

    games = @games.map(&:attributes)
    render json: games
  end

  def per_page
    [params[:limit].to_i, 50].min
  end
end
