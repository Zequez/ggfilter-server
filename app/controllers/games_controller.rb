class GamesController < ApplicationController
  def index
    @games = Game.limit(100)
  end
end
