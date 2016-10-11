class FiltersController < ApplicationController
  def index
    if params[:user_id]
      @filters = Filter.where(user_id: params[:user_id])
    else
      @filters = Filter.where.not(official_slug: nil).order('visits DESC')
    end
    render json: @filters
  end

  def create
    @filter = Filter.new(filter_params)
    if current_user
      @filter.user = current_user
    end
    @filter.save!
    render json: @filter
  end

  def update
    @filter = Filter.find_by_sid!(params[:id])
    if (current_user && @filter.user == current_user) || is_admin?
      @filter.update! filter_params
      render json: @filter
    else
      render json: {}, status: :unauthorized
    end
  end

  def show
    @filter = if params[:id] != '0'
      Filter.find_by_sid!(params[:id])
    elsif params[:official_slug]
      Filter.find_by_official_slug!(params[:official_slug])
    elsif params[:user_slug] && params[:user_id]
      Filter.find_by(user_id: params[:user_id], user_slug: params[:user_slug])
    end

    render json: @filter
  end

  def destroy
    if current_user
      filter = Filter.find_by_sid!(params[:id])
      if is_admin? || filter.user == current_user
        filter.delete
        render json: filter
      else
        render json: {}, status: :unauthorized
      end
    else
      render json: {}, status: :unauthorized
    end
  end

  private

  def filter_params
    if current_user
      is_admin? ? admin_filter_params : user_filter_params
    else
      anonymous_filter_params
    end
  end

  def anonymous_filter_params
    params.required('filter').permit('filter', 'name')
  end

  def user_filter_params
    params.required('filter').permit('filter', 'name', 'user_slug')
  end

  def admin_filter_params
    params.required('filter').permit('filter', 'name', 'user_slug', 'official_slug')
  end
end
