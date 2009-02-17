class Users::GroupsController < ApplicationController

  include UserMethods

  before_filter :login_required
  before_filter :get_user

  cache_sweeper :groups_sweeper, :only => [:create]

  # if a user exists in the request show groups for that user.  If not then show all groups
  def index

    @groups = @user.groups.paginate(:page => @page, :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  def new
    @group = Group.new
    @groups = Group.find(:all, :conditions => 'visibility > 0', :limit => 16, :order => 'created_at desc')
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  def create
    @group = Group.new(params[:group])
    @group.creator = @user
    @group.save!
    respond_to do |format|
      flash[:notice] = _('Group was successfully created.')
      format.html { redirect_to(@group) }
      format.xml  { render :xml => @group, :status => :created, :location => @group }
    end
  rescue
    flash[:notice] = _('There was a problem creating the group.  Please try again.')
    respond_to do |format|
      format.html { render :action => "new" }
      format.xml { render :xml => @group.errors, :status => :unprocessable_entity }
    end
  end

end
