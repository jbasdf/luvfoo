class PagesController < ApplicationController

  include PageMethods

  before_filter :get_site
  before_filter :get_site_content_page

  def show

    @title = @content_page.title

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content_page }
    end

  end

end
