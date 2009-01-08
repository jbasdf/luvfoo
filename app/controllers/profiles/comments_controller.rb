class Profiles::CommentsController < ApplicationController
    
    include ApplicationHelper
    
    def index
        @user = User.find_by_login(params[:profile_id])
        
        if is_me?(@user) 
            redirect_to profile_path(current_user)
            return 
        end

        @comments = Comment.between_users(current_user, @user).paginate(:page => @page, :per_page => @per_page)
        @count = @comments.total_entries
        
        respond_to do |format|
            format.html {render}
            format.rss {render :layout=>false}
        end
    end

end
