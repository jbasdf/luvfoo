class SessionsController < ApplicationController

  skip_filter :store_location
  before_filter :store_return_to
  before_filter :login_required, :only => :destroy
  before_filter :not_logged_in_required, :only => [:new, :create]

  # render new.rhtml
  def new
    @title = _("Sign In")
    render
  end

  def show
    redirect_to login_path
  end

  def create
    @title = _("Sign In")
    if using_open_id?
      begin
        open_id_authentication(params[:openid_url])
      rescue ActiveRecord::RecordInvalid => error
        # validation failed
        failed_login(_('Sorry could not log in with identity URL.  It is possible that your login or email is already in use.  If you already have an account, log into your account and then associate your Open ID with that account.'))
      end
    else  
      password_authentication(params[:login], params[:password])
    end
  end

  def destroy
    @title = _("Sign Out")
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    delete_plone_cookie
    reset_session
    flash[:notice] = _("You have been logged out.")
    redirect_to login_path
    #redirect_back_or_default('/')
  end

  protected

  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(identity_url)
        if @user.new_record?
          if !registration['nickname'].blank? && !registration['email'].blank?
            @user.login = registration['nickname']
            @user.email = registration['email']
            create_open_id_user(@user)
          else
            flash[:error] = _("Your account must include at a minimum a nickname and valid email address to use OpenID on this site.")
            render :action => 'new'
          end
        else
          if @user.activated_at.blank?  
            failed_login(_("Your account is not active, please check your email for the activation code."))
          elsif @user.enabled == false
            failed_login(_("Your account has been disabled."))
          else
            self.current_user = @user
            successful_login
          end        
        end
      else
        failed_login result.message
      end
    end
  end

  def create_open_id_user(user)
    user.save!
    flash[:notice] = _("Thanks for signing up! Please check your email to activate your account before logging in.")
    redirect_to login_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = _("Someone has signed up with that nickname or email address. Please select a diferent username and/or use a different email address.")
    render :action => 'new'
  end    

  def password_authentication(login, password)
    user = User.authenticate(login, password)
    if user == nil
      failed_login(_("We're sorry, but we couldn't recognize your login information.  Please try again."))
    elsif user.activated_at.blank?  
      failed_login(_("Your account is not active, please check your email for the activation code."))
    elsif user.enabled == false
      failed_login(_("Your account has been disabled."))
    else
      self.current_user = user
      successful_login
    end
  end

  private

  def failed_login(message)
    flash.now[:error] = message
    render :action => 'new'
  end

  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    write_plone_cookie
    flash[:notice] = _("Logged in successfully")
    return_to = get_return_to
    if return_to.nil?
      redirect_to user_path(self.current_user)
    else
      redirect_to return_to
    end
  end

  protected 

  def write_plone_cookie
    return unless GlobalConfig.integrate_plone
    require 'digest'
    require 'base64'
    cookie_str = Digest.hexencode(params[:login]) + ':' + Digest.hexencode(params[:password])
    cookie_val = Base64.b64encode(cookie_str).rstrip  
    cookies[:__ac] = { :value => cookie_val, :expires => self.current_user.remember_token_expires_at, :path => '/', :domain => '.' + GlobalConfig.application_base_url }
  end

  def delete_plone_cookie
    return unless GlobalConfig.integrate_plone
    cookies[:__ac] = { :value => nil, :domain => '.' + GlobalConfig.application_base_url, :expires => Time.at(0) }
    # cookies.delete :__ac Delete doesn't work for some reason
  end

  def permission_denied      
    respond_to do |format|
      format.html do
        redirect_to user_path(current_user)
      end
    end
  end    
end

