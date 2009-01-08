class Groups::CommentsController < ApplicationController
    
    include ApplicationHelper
    include GroupMethods
    
    before_filter :get_group

    def index
        @can_participate = @group.can_participate?(current_user)
        @comments = @group.comments.paginate(:page => @page, :per_page => @per_page)
        respond_to do |format|
            format.html {render}
            format.rss {render :layout=>false}
        end
    end

end
