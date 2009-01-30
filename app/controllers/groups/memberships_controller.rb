class Groups::MembershipsController < ApplicationController

  include GroupMethods
  include GroupsHelper
  before_filter :get_group
  before_filter :setup
  before_filter :login_required, :except => [:index]

  def index
    @per_page = 50
    @members = @group.members.paginate(:page => @page, :per_page => @per_page)

    respond_to do |format|
      format.html do
        if manager?
          render :template => 'groups/admin/index'
        else
          render
        end 
      end
      format.rss { render :layout => false }
    end
  end

  def new
    respond_to do |format|
      format.html do
        if @group.is_member?(current_user)
          flash[:notice] = _("You are already a member of %{group_name}") % { :group_name => @group.name}
          redirect_to group_path(@group)
        else
          render
        end
      end
    end
  end
  
  def create
    user = current_user
    accepting_pledge = false
    if params[:user_id] && user.login != params[:user_id]
      raise(Exception.new, 'Non admin user tried to accept a pledge') if !manager?
      user = User.find_by_login(params[:user_id]) || User.find(params[:user_id])
      accepting_pledge = true
    end

    unless @group.is_member?(user)
      if @group.requires_approval_to_join == true
        if accepting_pledge
          @group.remove_pledge(user)
          @membership = @group.memberships.create!(:user_id => user.id, :role => @group.default_role)
          message = _("You have joined the group <b>%{group_name}</b>.") % { :group_name => @group.name}
          respond_to do |format|
            format.html do
              flash[:notice] = message
            end
            format.js { render :text => _('(accepted!)') }
            format.xml { render :xml => @membership, :status => :created, :location => @group }
          end
        else
          message = _("You have request to joined the group <b>%{group_name}</b>.  Your membership is pending and will be reviewed by a group administrator.") % { :group_name => @group.name}
          pledge = MembershipRequest.create!(:user_id => user.id, :group_id => @group.id)
          respond_to do |format|
            format.html do
              flash[:notice] = message
              render :action => 'new'
            end
            format.js { render :partial => 'groups/pending_request', :locals => { :message => message } }
            format.xml { render :xml => @membership, :status => :created, :location => @group }
          end
        end
      else
        @membership = @group.memberships.create!(:user_id => user.id, :role => @group.default_role)
        message = _("You have joined the group <b>%{group_name}</b>.") % { :group_name => @group.name}
        respond_to do |format|
          format.html do
            flash[:notice] = message
            redirect_to group_path(@group)
          end
          format.js { render :partial => 'groups/member_controls', :locals => {:message => message } }
          format.xml { render :xml => @membership, :status => :created, :location => @group }
        end
      end
    else
      respond_to do |format|
        format.html do
          flash[:notice] = _("You are already a member of %{group_name}") % { :group_name => @group.name}
          redirect_to group_path(@group)
        end
        format.js { render :partial => 'groups/member_controls' }
      end      
    end

  rescue Exception => e
    #puts e.message
    message = _("An error occured while joining the group.  Please try again.")
    respond_to do |format|
      format.html do
        flash[:error] = message
        redirect_to group_path(@group)
      end
      format.js do
        render :partial => 'groups/join_controls', :locals => { :message => message }
      end
      format.xml { render :xml => e, :status => :unprocessable_entity }
    end
  end

  def destroy
    if @group.is_member?(current_user)
      @group.remove_member(current_user)
    end
    render :partial => 'groups/join_controls', :locals => {:message => _("You have left the group"), :rejoin => true }
  end

  private
  
  def setup
    if !@group
      flash[:notice] = _("There was a problem with the group.  Please try again.")
      permission_denied 
    else
      @can_participate = @group.can_participate?(current_user)
    end
  end

end