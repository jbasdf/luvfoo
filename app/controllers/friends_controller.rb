class FriendsController < ApplicationController

  include UserMethods
  
  before_filter :login_required, :except => :index
  skip_before_filter :store_location, :only => [:create, :destroy]
  before_filter :get_user, :only => [:create, :destroy]
  before_filter :get_target, :only => [:create, :destroy]
    
  def index
    @user = User.find_by_login(params[:user_id])
    respond_to do |format|
      format.html
    end
  end
  
  def create
    respond_to do |format|
      if Friend.make_friends(@user, @target)
      
        friend = current_user.reload.friend_of? @target
      
        format.html do
          if GlobalConfig.allow_following
            flash[:notice] = _("You are now following %{user}" % {:user => @target.login})
          else
            flash[:notice] = _('Friend Request Sent')
          end             
          redirect_to profile_path(@target)
        end
      
        format.js { render( :update ) {|page| page.replace make_id(@user, @target), get_friend_link(@user, @target)}}
      
      else
      
        if GlobalConfig.allow_following
          message = _("There was a problem adding %{user} to your follow list.  Please try again." % {:user => @target.login})
        else
          message = _("There was a problem sending a friend request to %{user}.  Please try again." % {:user => @target.login})
        end
        
        format.html do
          flash[:notice] = message
          redirect_to profile_path(@target)
        end
      
        format.js {render( :update ){|page| page.alert message}}
      
      end
    end
  end

  def destroy

    if GlobalConfig.allow_following
      # only allow the user to reset friend relationships they have created
      Friend.reset @user, @target 
    else
      # let any user delete a friend request related to them
      Friend.reset @user, @target
      Friend.reset @target, @user
    end

    respond_to do |format|
      
      format.html do
        flash[:notice] = _('Removed friend relationship')
        redirect_to profile_path(@target)
      end
      
      format.js do
        render( :update ){|page| page.replace make_id(@user, @target), get_friend_link(@user, @target)}
      end
      
      #format.xml {head :ok }
      
    end

  end
  
  protected
  
  def make_id(user, target)
    user.dom_id(target.dom_id + '_friendship_')
  end
  
  def get_target
    @target = User.find_by_login(params[:id]) || User.find(params[:id])
  end
  
end
