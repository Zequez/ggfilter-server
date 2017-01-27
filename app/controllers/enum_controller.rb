class EnumController < ApplicationController
  def index
    render json: {
      stores: Game.stores_flags,
      players: Game.players_flags,
      controllers: Game.controllers_flags,
      vr_platforms: Game.vr_platforms_flags,
      vr_modes: Game.vr_modes_flags,
      platforms: Game.platforms_flags
    }
  end
end
