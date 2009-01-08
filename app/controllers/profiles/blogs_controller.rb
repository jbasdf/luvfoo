class Profiles::BlogsController < ApplicationController
      
    before_filter :setup
    
    def index
        if @user.blogs.empty?
            flash[:notice] = _("%{name} hasn't written any blog posts yet." % {:name => @user.full_name })
        end
        respond_to do |format|
            format.html {render}
            format.rss {render :layout=>false}
        end
    end

    def show
        @blog = @user.blogs.find_by_url_key(params[:id])
        if @blog.nil?
            flash[:notice] = _("Could not find the requested blog post")
            redirect_to profile_blogs_path(@user)
        else
            respond_to do |format|
                format.html {render}
                format.rss {render :layout=>false}
            end
        end
    end

    protected

    def setup
        @user = User.find_by_login(params[:profile_id]) || User.find(params[:profile_id])
        @blogs = @user.blogs.paginate(:page => @page, :per_page => @per_page)
    end

end
