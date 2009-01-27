class UploadsController < ApplicationController

  include UserMethods
  include UrlMethods
  include JsonMethods
  
  # Pass sessions through to allow cross-site forgery protection
  #protect_from_forgery :except => :swfupload
  session :cookie_only => false, :only => :swfupload
  
  skip_filter :store_location
  before_filter :login_required
  before_filter :get_user
  before_filter :authorization_required, :except => [:swfupload]
  before_filter :get_parent, :only => [:create, :swfupload]
  
  def create
    
    # Standard, one-at-a-time, upload action
    @upload = @parent.uploads.build(params[:upload])
    @upload.user = current_user
    @upload.save!
    message = _('Successfully uploaded file.')
    upload_json = basic_uploads_json(@upload)
    
    respond_to do |format|

      format.html do
        flash[:notice] = message
        redirect_to get_redirect
      end
            
      format.js do
        responds_to_parent do
          render :update do |page|
            page << "upload_file_callback('#{upload_json}');"
          end
        end
      end
      
    end
  rescue => ex
    message = _("An error occured while uploading the file: %{error}.  Please ensure that the file is valid.  
      Checkt to make sure the file is not empty.  Then try again." % {:error => ex})
    #message = _("An error occured while uploading the file.  Please try again.")
    respond_to do |format|
      format.html do
        flash[:notice] = message
        redirect_to get_redirect
      end
      format.js do
        responds_to_parent do
          render :update do |page|
            page << "upload_file_fail_callback('#{message}');"
          end
        end
      end
      #format.js { render :text => message }
    end
  end

  def swfupload
    # swfupload action set in routes.rb
    @upload = @parent.uploads.build(:uploaded_data => params[:Filedata])
    @upload.is_public = true if params[:is_public] == true
    @upload.user = current_user
    @upload.save!

    respond_to do |format|
      format.json do
        render :text => basic_uploads_json(@upload)
      end
      format.js do
        # return a table row
        case @parent
        when User
          render :partial => 'uploads/upload_row', :object => @upload, :locals => {:style => 'style="display:none;"', :parent => @parent, :share => true}
        when Group  
          render :partial => 'uploads/upload_row', :object => @upload, :locals => {:style => 'style="display:none;"', :parent => @parent}
        else
          raise 'not implemented'
        end
      end
    end
  rescue => ex
    render :text => _("An error occured while uploading the file.")
    #render :text => _("Error %{exception}")  % {:exception => ex}
  end

  def destroy

    @upload = Upload.find(params[:id])
    @parent = @upload.uploadable # set this for redirect
    
    if @upload.can_edit?(current_user)
      @upload.destroy 
      msg = _('Deleted file')
    else
      msg = _("You don't have permission to delete that file.")
    end
    
    respond_to do |format|
      format.html do
        flash[:notice] = msg
        redirect_back_or_default get_redirect
      end
      format.js { render :text => msg }
    end
  
  end
  
  # figure out how to add a link that will open docs directly into google docs
  # def google_upload
  #   if @upload.can_edit?(@user)
  #     require 'feed-normalizer'
  #     headers = { 'Content-Type' => 'application/atom+xml',
  #                 'Authorization' => 'AuthSub token="' + params[:token] + '"'}
  #     response = UrlMethods.get('http://docs.google.com/feeds/documents/private/full', headers)
  #     documents = FeedNormalizer::FeedNormalizer.parse response.body
  #     redirect_to user_uploads_path(@user)        
  #   else
  #     flash[:notice] = _("You don't have permission to upload this to Google Docs.")
  #     redirect_to user_uploads_path(@user)
  #   end    
  # end
    
  protected

  def get_parent
    
    if !params[:type] || !params[:id]
      raise 'Please specify a parent object via type and id'
      return
    end
    case params[:type]
    when 'User'
      @parent = User.find(params[:id])
      unless @user == current_user || is_admin?
        permission_denied
      end
    when 'Site'
      @parent = Site.find(params[:id])
      # if the user isn't an admin they can't upload pictures to the site
      unless is_admin?
        permission_denied
      end
    when 'Widget'
      @parent = Widget.find(params[:id])
      # if the user isn't an admin they can't upload pictures to the site
      unless is_admin?
        permission_denied
      end
    when 'Group'
      @parent = Group.find(params[:id])
      # if the current_user isn't a member of the group they can't make comments
      unless @parent.is_member?(current_user) || is_admin?
        permission_denied
      end
    else
      permission_denied
    end
  end
  
  def permission_denied
    msg = _("You don't have permission to complete this action.")
    respond_to do |format|
      format.html do
        flash[:notice] = msg
        redirect_to get_redirect
      end
      format.js do
        render :text => msg
      end
    end
  end

  def get_redirect
    case @parent
    when User
      user_uploads_path(@parent)
    when Site
      if is_admin?
        uploads_path(@parent)
      else
        user_uploads_path(current_user)
      end
    when Group
      group_uploads_path(@parent)
    else
      # by default just go back to the user's uploads page
      user_uploads_path(current_user)
    end
  end
  
end