class Groups::PhotosController < ApplicationController

  include GroupMethods
  before_filter :login_required, :only => [:destroy, :create]
  before_filter :get_group
  before_filter :setup
  before_filter :authorization_required, :only => [:destroy] 
  before_filter :membership_required, :only => [:create]

  cache_sweeper :photos_sweeper, :only => [:create, :destroy]

  def index
    @per_page = 50
    @photos = @group.photos.paginate(:page => @page, :per_page => @per_page)

    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

  def show
    redirect_to group_photos_path(@group)
  end

  def create
    params[:photo][:creator_id] = current_user.id
    @photo = @group.photos.build params[:photo]

    respond_to do |format|
      if @photo.save
        format.html do
          flash[:notice] = 'Photo successfully uploaded.'
          redirect_to group_photos_path(@group)
        end
      else
        format.html do
          flash.now[:error] = 'Photo could not be uploaded.'
          render :action => :index
        end
      end
    end
  end

  def destroy
    Photo[params[:id]].destroy
    respond_to do |format|
      format.html do
        flash[:notice] = _('Photo was deleted.')
        redirect_to group_photos_path(@group)
      end
    end
  end


  private

  def setup
    @photos = @group.photos.paginate(:all, :page => @page, :per_page => @per_page)
    @photo = Photo.new
    @user = current_user
    @can_participate = @group.can_participate?(current_user)
  end

  def permission_denied 
    flash[:error] = _("You don't have permission to delete that photo.")     
    respond_to do |format|
      format.html do
        redirect_to group_photos_path(@group)
      end
    end
  end

end