class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session,
  #   if: Proc.new { |c| c.request.format.json? }

  protect_from_forgery only: Rails.env.production?

  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end
end
