class ScrapLogsController < ApplicationController
  def index
    respond_to do |f|
      f.json do
        render json: ScrapLog.for_index
      end
    end
  end
end
