class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session,
  #   if: Proc.new { |c| c.request.format.json? }

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end

  def is_admin?
    current_user && current_user.is_admin?
  end

  def record_not_found
    render json: {}, status: :not_found
  end
end
