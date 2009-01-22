module UserMethods

  protected

  # TODO decide if we need to keep this method or if we need to use authorized? from authenticated_system instead
  def authorization_required

    return true if is_admin?

    if !is_me?(@user)
      flash[:notice] = "You don't have permission to do that."
      permission_denied
      false
    end
  end

  def permission_denied      
    respond_to do |format|
      format.html do
        redirect_to profile_path(@user)
      end
    end
  end

  def get_user
    if is_admin?
      @user = User.find_by_login(params[:user_id]) || current_user
    else
      @user = current_user
    end

    if !@user
      flash[:notice] = "There was a problem finding your user information.  Please try again."
      permission_denied 
    end
  end

end
