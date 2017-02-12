class FiltersController < ApplicationController
  # def index
  #   if params[:user_id]
  #     @filters = Filter.where(user_id: params[:user_id])
  #   else
  #     @filters = Filter.where.not(official_slug: nil).order('visits DESC')
  #   end
  #   render json: @filters
  # end

  def create
    @filter = Filter.new(anonymous_filter_params)
    @filter.ip_address = request.remote_ip

    if current_user
      @filter.user = current_user
    end
    @filter.save!
    render json: @filter.to_json_create
  end

  def update
    @filter = Filter.find_by_sid!(params[:id])
    if params[:secret] == @filter.secret
      @filter.update! anonymous_filter_params
      render json: @filter.to_json_normal
    else
      render json: {}, status: :unauthorized
    end
  end

  def show
    @filter = Filter.find_by_sid!(params[:id])
    # @filter = if params[:id] != '0'
    #   Filter.find_by_sid!(params[:id])
    # elsif params[:official_slug]
    #   Filter.find_by_official_slug!(params[:official_slug])
    # elsif params[:user_slug] && params[:user_id]
    # #Filter.find_by(user_id: params[:user_id], user_slug: params[:user_slug])
    # end

    render json: @filter.to_json_normal
  end

  def destroy
    @filter = Filter.find_by_sid!(params[:id])
    if params[:secret] == @filter.secret
      @filter.delete
      render json: @filter.to_json_normal
    else
      render json: {}, status: :unauthorized
    end
  end

  private

  # def filter_params
  #   if current_user
  #     is_admin? ? admin_filter_params : user_filter_params
  #   else
  #     anonymous_filter_params
  #   end
  # end

  def anonymous_filter_params
    p = params.required('payload')
    # p.permit!('controls_params')
    # p.permit!('columns_params')
    # p.permit!('sorting')
    # p.permit!('global_config')
    p.permit(
      'name',
      'controls_list' => [],
      'controls_hl_mode' => [],
      'controls_params' => {},
      'columns_list' => [],
      'columns_params' => {},
      'sorting' => {},
      'global_config' => {}
    ).merge(permit_hashes(p, [
      'controls_params',
      'columns_params',
      'sorting',
      'global_config'
    ]))
  end

  def permit_hashes(p, names)
    result = {}
    names.each do |name|
      if p[name] && p[name].respond_to?(:to_h)
        result[name] = p[name].permit!.to_h
      end
    end
    result
  end



  # def user_filter_params
  #   params.required('filter').permit('filter', 'name', 'user_slug')
  # end
  #
  # def admin_filter_params
  #   params.required('filter').permit('filter', 'name', 'user_slug', 'official_slug')
  # end
end
