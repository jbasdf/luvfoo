class UsersController < ApplicationController

  skip_filter :store_location, :only => [:new, :create, :edit, :update, :destory, 
    :welcome, :is_login_available, :is_email_available,
    :enable, :delete_icon]
  before_filter :not_logged_in_required, :only => [:new, :create] 
  before_filter :login_required, :only => [:show, :edit, :update, :share, :delete_icon]
  before_filter :check_administrator_role, :only => [:destroy, :enable]

  def index
    respond_to do |format|
      format.html { redirect_to profiles_path }
    end
  end
  
  # Show the user's home page.  This is their 'dash board'
  def show  
    @title = _('Dashboard')
    unless current_user.youtube_username.blank?
      begin
        client = YouTubeG::Client.new
        @video = client.videos_by(:user => current_user.youtube_username).videos.first
      rescue Exception, OpenURI::HTTPError
      end
    end

    begin
      @flickr = current_user.flickr_username.blank? ? [] : flickr_images(flickr.people.findByUsername(current_user.flickr_username))
    rescue Exception, OpenURI::HTTPError
      @flickr = []
    end    

    @comments = current_user.comments.paginate(:page => @page, :per_page => @per_page)
    @user = current_user
    @google_docs = @user.google_docs 
    @to_list = @user.friends
    @content_pages = @user.content_pages
    @shared_uploads = @user.shared_uploads.find(:all, :limit => 5, :order => 'created_at DESC')
    @feed_items = current_user.feed_items.paginate(:page => @page, :per_page => @per_page)
    
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  end   

  def new
    @title = _("Register for an account")

    @user = User.new
    respond_to do |format|
      format.html { render }
    end
  end

  def create
    @title = _("Register for an account")

    cookies.delete :auth_token

    User.transaction do
      @user = User.new
      @user.save(false)
      @user.update_property_bag params[:property], params[:v], params[:dt]
      @user.properties_for_page(1) # cache the properties in the user model in case the validation fails they can be restored to the form
      params[:user][:terms_of_service] = true
      params[:user][:tmp_password] = params[:user][:password]
      @user.attributes = params[:user]
  
      if GlobalConfig.use_recaptcha
        if !(verify_recaptcha(@user) && @user.valid?)
          raise ActiveRecord::RecordInvalid, @user
        else
          @user.save(false)
        end
      else
        @user.save!
      end
    end
    
    expire_profile_directory_cache(@user)

    if GlobalConfig.automatically_activate
      # Automatically activate the user.  This can be used safely if captcha is in place
      @user.force_activate!
    end
    
    if GlobalConfig.automatically_login_after_account_create
      # Have the user logged in after creating an account - Not Recommended
      self.current_user = @user
    end
        
    send_welcome_msg

    begin
      if GlobalConfig.automatically_activate
        # usually information is not sent to Salesforce unless the user activates their
        # account.  Since we no longer do activation we have to do it here.
        @user.salesforce_sync if GlobalConfig.integrate_salesforce
        Plone.user_to_plone(@user,params[:user][:password]) if GlobalConfig.integrate_plone
      end
    rescue ActiveRecord::RecordInvalid => e
      # do nothing.  Just let the sync fail
    end

    if GlobalConfig.automatically_activate          
      if GlobalConfig.automatically_login_after_account_create
        redirect_to edit_user_path(@user) + '?fv=true'
      else
        flash[:notice] = _("Thanks for signing up! You may login now")
        redirect_to login_path
      end
    else
      flash[:notice] = _("Thanks for signing up! Please check your email to activate your account and then login.")
      redirect_to welcome_user_path(@user)
    end

  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :action => "new" }
    end
  end

  def send_welcome_msg
    welcome_msg = NewsItem.find_by_title(_('Welcome to TWB!'))
    welcome_msg = Site.first.news_items.build(
    :title => _('Welcome to TWB!'), 
    :body => _('See the %{getting_started_link_anchor}getting started page%{getting_started_link_end} to learn more about what you can do here.') % { 
        :getting_started_link_anchor => '<a href="' + content_path(:content_page => 'getting_started', :locale => locale.to_s) + '">', 
        :getting_started_link_end => "</a>"}) if !welcome_msg 
  end

  def help
    @title = _("Help")
    respond_to do |format|
      format.html { render }
    end
  end

  def getting_started
    @title = _("Getting Started")
    respond_to do |format|
      format.html { render }
    end
  end

  def welcome
    @title = _("Welcome")
    @user = User.find_by_login(params[:id])
    respond_to do |format|
      format.html { render }
    end
  end

  def is_login_available
    result = 'Username not available'

    if params[:user_login] && params[:user_login].length <= 0
      result = ''
    elsif !User.login_exists?(params[:user_login])

      @user = User.new(:login => params[:user_login])
      if !@user.validate_attributes(:only => [:login])
        result = ''
        @user.errors.full_messages.each do |message|
          if !message.include? 'blank'
            result += "#{message}<br />"
          end
        end
      else
        result = 'Username available'
      end
    end
    respond_to do |format|
      format.html { render :text => result}
    end
  end

  def is_email_available
    result = 'Email already in use'

    if params[:user_email] && params[:user_email].length <= 0
      result = ''
    elsif !User.email_exists?(params[:email_login])
      result = 'Email available'
    end
    respond_to do |format|
      format.html { render :text => result}
    end
  end

  def edit
    @title = _("Update your profile")
    @user = User.find_by_login(params[:id])

    return unless allowed_access?(:owner => current_user, :object_user_id => @user.id, :permit_roles => ['administrator']) 

    respond_to do |format|
      format.html { render }
    end

  end

  def update
    @title = _("Update your profile")

    @user = is_admin? ? User.find_by_login(params[:id]) : User.find(current_user)
    had_avatar = !@user.icon.nil?

    if @user.update_from_params params
      expire_profile_directory_cache(@user)
      @user.salesforce_sync if GlobalConfig.integrate_salesforce
      flash[:notice] = _("Settings have been saved.")
      redirect_to is_admin? ? profile_path(@user) : user_path(@user) 
    else
      flash.now[:error] = @user.errors
      respond_to do |format|
        format.html { render :action => :edit}
      end
    end

  end      

  def destroy
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, false)
      flash[:notice] = _("User disabled")
    else
      flash[:error] = _("There was a problem disabling this user.")
    end
    redirect_to :action => 'index'

    #TODO if the user deletes their account it should remove the data from salesforce as well

    #TODO figure out what to do here - should we really delete the account or just disable it?
    # respond_to do |format|
    #               @user.destroy
    #               cookies[:auth_token] = {:expires => Time.now-1.day, :value => ""}
    #               session[:user] = nil
    #               format.js do
    #                   render :update do |page| 
    #                       page.alert('Your user account, and all data, have been deleted.')
    #                       page << 'location.href = "/";'
    #                   end
    #               end
    #           end
  end


  def enable
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, true)
      self.current_user = @user
      flash[:notice] = _("User enabled")
    else
      flash[:error] = _("There was a problem enabling this user.")
    end
    redirect_to :action => 'index'
  end

  def delete_icon
    respond_to do |format|
      user = is_admin? ? User.find_by_login(params[:id]) : current_user
      user.update_attribute :icon, nil
      format.js { render(:update){|page| page.visual_effect :puff, 'avatar_edit'}}
    end      
  end

  protected 

  def permission_denied      
    respond_to do |format|
      format.html do
        redirect_to user_path(current_user)
      end
    end
  end
  
  def expire_profile_directory_cache(user)
    expire_fragment(:controller => 'profiles', :action => 'snippet', :id => user.id)
    expire_fragment(%r{profiles.*})
  end

end
