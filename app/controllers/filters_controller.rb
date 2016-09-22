class FiltersController < ApplicationController
  def create
    filter = Filter.create(filter_params)
    render json: filter
  end

  def show
    render json: Filter.find_by_sid(params[:id])
  end

  private

  def filter_params
    params.required('filter').permit('filter')
  end
end
