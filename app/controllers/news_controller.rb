class NewsController < ApplicationController

  skip_filter :store_location, :only => [:index]

  def index
    respond_to do |format|
      format.html { render }
    end
  end

end