class Groups::News::CommentsController < ApplicationController
    
    include ApplicationHelper
     
    before_filter :setup

    def index
        @comments = @group.comments.paginate(:page => @page, :per_page => @per_page)
        respond_to do |format|
            format.html {render}
            format.rss {render :layout=>false}
        end
    end  

    protected

    def setup
        @news_item = NewsItem.find_by_url_key(params[:news_item_id]) || NewsItem.find(params[:news_item_id])
    end

end
