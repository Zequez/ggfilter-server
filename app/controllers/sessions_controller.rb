class SessionsController < Devise::SessionsController
  respond_to :json

  def show
    if current_user
      render json: current_user
    else
      render json: {}
    end
  end
end
