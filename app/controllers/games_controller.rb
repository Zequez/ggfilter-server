class GamesController < ApplicationController
  def index
    L params[:filters]
    @games = Game
      .select(columns)
      .apply_filters(params[:filters])
      .limit(20)

    respond_to do |f|
      f.html
      f.json { render json: @games }
    end
    # @requirements = Game.all.pluck(:system_requirements)
  end

  def allowed_columns
    @allowed_columns ||= [
      'id', 'steam_id', 'name',
      'steam_price', 'steam_sale_price', 'released_at',
      'platforms', 'tags', 'genre', 'metacritic', 'summary',
      'players', 'controller_support', 'features',
      'positive_steam_reviews_count', 'negative_steam_reviews_count'
    ]
  end

  def columns
    columns = (allowed_columns - (allowed_columns - params[:columns]))
    columns.empty? ? allowed_columns : columns
  end
end
