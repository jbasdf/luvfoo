class GroupsController < ApplicationController

  include GroupsHelper
  include GroupMethods
  before_filter :login_required, :except => [:index, :show, :search]
  before_filter :setup, :except => [:index, :search]
  before_filter :authorization_required, :only => [:edit, :update, :destroy] 

  cache_sweeper :groups_sweeper, :only => [:create, :update, :destroy]

  # if a user exists in the request show groups for that user.  If not then show all groups
  def index
    @visibility_threshold = is_admin? ? -1 : 0
    if params[:alpha_index]
      @alpha_index = params[:alpha_index]
      @groups = Group.find(:all, :conditions => ["visibility > ? AND name LIKE ?", @visibility_threshold, @alpha_index + '%'], :order => 'name').paginate(:page => @page, :per_page => @per_page)
    else
      @groups = Group.find(:all, :conditions => ["visibility > ?", @visibility_threshold], :order => 'name').paginate(:page => @page, :per_page => @per_page)
    end
    #@my_groups = logged_in? ? current_user.public_groups : []
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  def search
    @query = params[:q]
    if (@query.nil? or @query == '*')
      redirect_to '/groups'#
      return
    end 
    @groups = Group.find_by_solr(@query, :limit => @per_page).results
    flash[:notice] = @groups.empty? ? _('No groups were found that matched your search.') : nil
    respond_to do |format|
      format.html { render :template => 'groups/index'}
      format.xml  { render :xml => @groups }
    end
  end

  def show
    if @group && ((@group.visibility > Group::INVISIBLE || @group.is_member?(current_user) || is_admin?))
      @user = current_user
      @visible = @group.is_content_visible?(current_user)
      if @visible == true
        @comments = @group.comments.find(:all, :limit => 5, :order => 'created_at DESC')
        @photos = @group.photos.paginate(:page => @page, :per_page => @per_page)
        @members = @group.members.in_role(:member, :limit => 10)
        @news = @group.news_items.find(:all, :limit => 5, :order => 'created_at DESC')
        @google_docs = @group.public_google_docs
        @shared_uploads = @group.shared_uploads.find(:all, :limit => 5, :order => 'created_at DESC')
      end

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @group }
      end
    else
      message = _('Requested group does not exist.')
      respond_to do |format|        
        format.html do
          flash[:notice] = message
          redirect_to groups_path
        end
        format.xml do
          render :xml => '<message>' + message + '</message>'
        end
      end
    end         
  end

  def edit
  end

  def update
    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = _('Group was successfully updated.')
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group.delete!
    flash[:notice] = _('Group was successfully removed.')
    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  def delete_icon
    respond_to do |format|
      @group.update_attribute :icon, nil
      format.js {render :update do |page| page.visual_effect 'Puff', 'group_icon_picture' end  }
    end      
  end

  def update_memberships_in
    if manager?
      params[:group_member_role].each do |member_id, role|
        membership = @group.memberships.find_by_user_id(member_id)
        membership.role = role
        membership.save!
      end
      flash[:notice] = _('Member roles were updated.')
    end
    redirect_to group_path(@group)
  end

  private
  def setup
    @group = Group.find_by_url_key(params[:id]) rescue nil
    @group = Group.find(params[:id]) rescue nil if @group.nil?
    @can_participate = @group ? @group.can_participate?(current_user) : false
  end

end
 
 