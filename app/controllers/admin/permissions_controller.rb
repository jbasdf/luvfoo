class Admin::PermissionsController < Admin::BaseController
  
  def create
    user = User.find_by_login(params[:login])
    if !user
      message = _("Could not add the specified permission.  Unable to find a user with login '%{user}'") % { :user => params[:login] }
      respond_to do |format|
        format.html { render :action => "new" }
        format.js { render :json => {:message => message, :success => false}.to_json }
      end
    else
      role = Role.find(params[:role_id])
      @permission = Permission.new
      @permission.role = role
      @permission.user = user
      respond_to do |format|
        if @permission.save
          message = _("Successfully added %{user} to role '%{role}'.")  % { :user => user.login, :role => role.rolename }
          row = render_to_string(:partial => 'admin/roles/permission', :object => @permissions)
          format.html do
            flash[:notice] = message
            redirect_to(admin_roles_path)
          end
          format.js { render :json => {:message => message, :row => row, :role_dom_id => role.dom_id, :success => true}.to_json }
        else
          message = _("Unable to add %{user} to role %{role}") % { :user => user.login, :role => role.rolename }
          format.html { render :action => "new" }
          format.js { render :json => {:message => message, :success => false}.to_json }
        end
      end
    end
  end
  
  def destroy
    @permission = Permission.find(params[:id], :include => [:user, :role])
    @permission.destroy
    message = _("%{user} was successfully removed from role '%{role}'") % { :user => @permission.user, :role => @permission.role }
    respond_to do |format|
      format.html do
        flash[:notice] = message
        redirect_to admin_roles_path        
      end
      format.js do
        render :json => {:message => message, :success => true, :id => @permission.id }.to_json
      end
    end
  end
  
end