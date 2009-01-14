class Admin::RolesController < Admin::BaseController

  def index
    @roles = Role.find(:all, :include => [:users])
    @role = Role.new
    @permission = Permission.new
  end

  def show
    @role = Role.new(params[:role])
  end

  # POST /websites
  # POST /websites.xml
  def create
    @role = Role.new(params[:role])
    respond_to do |format|
      if @role.save
        flash[:notice] = _('Role was successfully created.')
        format.html { redirect_to(admin_roles_path) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    flash[:notice] = _('Role was successfully deleted.')
    redirect_to :action => 'index'
  end

end

