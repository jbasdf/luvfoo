class PasswordsController < ApplicationController

  skip_filter :store_location
  before_filter :login_required, :except => [:new, :create, :edit, :update]
  before_filter :not_logged_in_required, :only => [:new, :create, :edit, :update]

  # Enter email address to recover password 
  def new
    @title = _("Recover Password")
    render
  end

  # Forgot password action
  def create
    @title = _("Recover Password")    
    return unless request.post?
    if @user = User.find_for_forget(params[:email])
      @user.forgot_password
      @user.save      
      flash[:notice] = _("A password reset link has been sent to your email address.")
      redirect_to login_path
    else
      flash[:notice] = _("Could not find a user with that email address.")
      render :action => 'new'
    end  
  end

  # Action triggered by clicking on the /reset_password/:id link recieved via email
  # Makes sure the id code is included
  # Checks that the id code matches a user in the database
  # Then if everything checks out, shows the password reset fields
  def edit
    @title = _("Reset Password")
    if params[:id].nil?
      render :action => 'new'
      return
    end
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    raise if @user.nil?
  rescue
    logger.error _("Invalid Reset Code entered.")
    flash[:notice] = _("Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)")
    #redirect_back_or_default('/')
    redirect_to new_user_path
  end

  # Reset password action /reset_password/:id
  # Checks once again that an id is included and makes sure that the password field isn't blank
  def update
    @title = _("Reset Password")
    if params[:id].nil?
      flash[:notice] = _("Could not find a password reset code.  Please try resetting your password again")
      render :action => 'new'
      return
    end
    if params[:password].blank?
      flash[:notice] = _("Password field cannot be blank.")
      render :action => 'edit', :id => params[:id]
      return
    end
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    raise if @user.nil?
    return if @user unless params[:password]
    if (params[:password] == params[:password_confirmation])
      #Uncomment and comment lines with @user to have the user logged in after reset - not recommended
      #self.current_user = @user #for the next two lines to work
      #current_user.password_confirmation = params[:password_confirmation]
      #current_user.password = params[:password]
      #@user.reset_password
      #flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
      @user.password_confirmation = params[:password_confirmation]
      @user.password = params[:password]
      @user.reset_password        
      flash[:notice] = @user.save ? _("Password reset.") : _("Password not reset.")
    else
      flash[:notice] = "Password mismatch."
      render :action => 'edit', :id => params[:id]
      return
    end

    redirect_to login_path

  rescue
    logger.error _("Invalid Reset Code entered")
    flash[:notice] = _("Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)")
    redirect_to new_user_path
  end

  private 
  def permission_denied
    respond_to do |format|
      format.html do
        redirect_to current_user
      end
    end
  end

end

