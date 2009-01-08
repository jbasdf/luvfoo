class Users::PhotosController < ApplicationController

  before_filter :login_required, :only => [:destroy, :create]
  before_filter :setup

  cache_sweeper :photos_sweeper, :only => [:create, :destroy]

  def index
    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

  def show
    redirect_to user_photos_path(@user)
  end

  def create
    params[:photo][:creator_id] = current_user.id
    @photo = @user.photos.build params[:photo]

    respond_to do |format|
      if @photo.save
        format.html do
          flash[:notice] = _('Photo successfully uploaded.')
          redirect_to user_photos_path(@user)
        end
      else
        format.html do
          flash.now[:error] = _('Photo could not be uploaded.')
          render :action => :index
        end
      end
    end
  end

  def destroy
    @photo = Photo[params[:id]]
    return unless can_edit_photo?(@photo)
    @photo.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = _('Photo was deleted.')
        redirect_to user_photos_path(@user)
      end
    end
  end


  protected

  def can_edit_photo?(photo)

    return true if is_admin?

    if @photo.photoable.id == current_user.id
      true
    else
      flash[:notice] = "You don't have permission to do that."
      permission_denied
      false
    end

  end


  private

  def setup
    @user = User.find_by_login(params[:user_id])
    @photos = @user.photos.paginate(:all, :page => @page, :per_page => @per_page)
    @photo = Photo.new
  end

  def permission_denied
    flash[:error] = _("You don't have permission to delete that photo.")      
    respond_to do |format|
      format.html do
        redirect_to user_photos_path(@user)
      end
    end
  end

end
