class AccountsController < ApplicationController

  skip_filter :store_location, :only => [:show]
  before_filter :login_required, :except => :show
  before_filter :not_logged_in_required, :only => :show

  # Activate action
  def show
    # Uncomment and change paths to have user logged in after activation - not recommended
    #self.current_user = User.find_and_activate!(params[:id])
    user = User.find_and_activate!(params[:id])

    if GlobalConfig.integrate_plone
      if Plone.user_to_plone(user, user.tmp_password)
        user.tmp_password = ''
        user.save
      end             
    end

    user.salesforce_sync if GlobalConfig.integrate_salesforce

    flash[:notice] = _("Your account has been activated! You can now login.")
    redirect_to login_path
  rescue ArgumentError
    flash[:notice] = _('Activation code not found. Please try creating a new account.')
    redirect_to new_user_path 
  rescue User::ActivationCodeNotFound
    flash[:notice] = _('Activation code not found. Please try creating a new account.')
    redirect_to new_user_path
  rescue User::AlreadyActivated
    flash[:notice] = _('Your account has already been activated. You can log in below.')
    redirect_to login_path
  end

  # Change password action  
  def update
    return unless request.post?

    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]        
        if current_user.save
          flash[:notice] = _("Password successfully updated.")
          redirect_to edit_user_path(current_user)                    
        else
          flash[:error] = _("There was a problem changing your password. %{errors}") % { :errors => current_user.errors.full_messages.to_sentence }
          redirect_to edit_user_path(current_user)
        end
      else
        flash[:error] = _("New password does not match the password confirmation.")
        @old_password = params[:old_password]
        redirect_to edit_user_path(current_user)     
      end
    else
      flash[:error] = _("Your old password is incorrect.")
      redirect_to edit_user_path(current_user)
    end 
  end

end

