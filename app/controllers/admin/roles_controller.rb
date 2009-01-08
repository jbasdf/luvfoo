class Admin::RolesController < Admin::BaseController

    def index
        @user = User.find(params[:user_id])
        @all_roles = Role.find(:all)
    end

    def show
        @role = Role.new(params[:role])
    end
    
    def new
        @role = Role.new(params[:role])
    end
    
    # POST /websites
    # POST /websites.xml
    def create
        @role = Role.new(params[:role])

        respond_to do |format|
            if @role.save
                flash[:notice] = _('Role was successfully created.')
                format.html { redirect_to(admin_roles_path(@role)) }
                format.xml  { render :xml => @role, :status => :created, :location => @role }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
            end
        end
    end
    
    def edit
        @role = Role.new(params[:role])
    end
    
    def update
        @user = User.find(params[:user_id])
        @role = Role.find(params[:id])
        unless @user.has_role?(@role.rolename)
            @user.roles << @role
        end
        redirect_to :action => 'index'
    end

    def destroy
        @user = User.find(params[:user_id])
        @role = Role.find(params[:id])
        if @user.has_role?(@role.rolename)
            @user.roles.delete(@role)
        end
        redirect_to :action => 'index'
    end
    
end

