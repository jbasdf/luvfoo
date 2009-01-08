class Groups::ActivitiesController < ApplicationController

  include UserMethods
  include GroupMethods
  
  before_filter :get_user
  before_filter :get_group

  def index
    @feed_items = @group.feed_items.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

end