class TagsController < ApplicationController
  def index
    response = []
    Tag.all.each{ |t| response[t.id] = t.name }

    respond_to do |f|
      f.json do
        render json: response
      end
    end
  end
end
