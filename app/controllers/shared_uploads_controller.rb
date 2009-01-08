class SharedUploadsController < ApplicationController

  include UserMethods
  before_filter :get_user, :except => [:for_group] 
  before_filter :authorization_required
  before_filter :get_upload, :only => [:new, :create]

  def index
    @shared_uploads = @user.uploads_shared_by_me.paginate(:page => @page, :per_page => @per_page, :include => [:upload], :order => 'created_at desc')
  end

  def for_me
    @shared_uploads = @user.shared_uploads.paginate(:page => @page, :per_page => @per_page, :include => [:upload], :order => 'created_at desc')
  end

  def for_group
    @group = Group.find_by_url_key(params[:group_id]) || Group.find(params[:group_id])
    @shared_uploads = @group.shared_uploads.paginate(:page => @page, :per_page => @per_page, :include => [:upload], :order => 'created_at desc')
    if !@group.is_member?(current_user)
      respond_to do |format|
        format.html do
          redirect_to group_path(@group)
        end
      end
    else
      respond_to do |format|
        format.html
      end
    end
    
  end

  def new
    @groups = @user.groups
    @friends = @user.friends + @user.followers
    @shared_upload = SharedUpload.new
  end

  def create

    if params[:public] == 'on'
      @upload.is_public = true
    else
      @upload.is_public = false
    end

    @upload.save

    @friend_ids = params[:friend_ids] || Array.new
    @upload.share_with_friends(@user, @friend_ids) if !@friend_ids.empty?

    @group_ids = params[:group_ids] || Hash.new
    @upload.share_with_groups(@user, @group_ids) if !@group_ids.empty?

    respond_to do |format|
      format.html do
        flash[:notice] = _('File was successfully shared')
        redirect_to user_uploads_path(@user)
      end
    end

  end

  def destroy

    @shared_upload = SharedUpload.find(params[:id])
    
    if @shared_upload.can_edit?(current_user)
      @shared_upload.destroy 
      respond_to do |format|
        format.html do
          flash[:notice] = _('Deleted shared file')
          redirect_to user_shared_uploads_path(@user)
        end
        format.js { render(:update){|page| page.visual_effect :fade, "shared_upload_#{params[:id]}".to_sym}}
      end
    else
      respond_to do |format|
        format.html do
          flash[:notice] = _("You don't have permission to delete the shared file.")
          redirect_to user_shared_uploads_path(@user)
        end
        format.js { render(:update){|page| page.alert _("You don't have permission to delete the shared file.")}}
      end
    end
  end

  def get_upload
    @upload = Upload.find(params[:upload_id])
  end

end
