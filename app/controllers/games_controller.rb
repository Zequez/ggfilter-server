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

  FLAGS_COLUMNS = [:stores, :players, :controllers, :vr_platforms, :vr_modes, :platforms, :gamepad]
  def index
    @games = Game
      .apply_filters(filter[:params] || {})
      .select_columns(filter[:columns] || {})
      .sort_by_column(filter[:sort] || {})
      .page(params[:page].to_i+1).per(per_page)

    response.headers['X-Pagination-Count'] = @games.total_count.to_s
    games = @games.map(&:attributes)

    selected_flags_columns = FLAGS_COLUMNS & filter[:columns].map(&:to_sym)
    unless selected_flags_columns.empty?
      games.each_with_index do |game, i|
        selected_flags_columns.each do |col|
          game[col] = @games[i].send(col)
        end
      end
    end

    render json: games
  end

  def per_page
    [params[:limit].to_i, 50].min
  end
end
