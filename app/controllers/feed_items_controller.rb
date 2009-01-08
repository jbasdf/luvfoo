class FeedItemsController < ApplicationController

  include ApplicationHelper

  skip_filter :store_location
  before_filter :login_required
  before_filter :setup

  def destroy
    
    @feed = @user.feeds.find_by_feed_item_id(params[:id])

    if @feed.feed_item.item.is_a?(StatusUpdate)
      @feed.feed_item.item.destroy
      @new_status = render_to_string(:partial => 'users/current_status', :locals => {:user => @user})
      @status_change = true
    end    
        
    @feed.destroy
      
    respond_to do |format|
      format.html do
        flash[:notice] = _('Item successfully removed from the recent activities list.')
        redirect_back_or_default @user
      end
      format.js do
        render(:update) do |page|
          page.visual_effect :puff, "feed_item_#{params[:id]}".to_sym
          if @status_change
            page.visual_effect :puff, "#current-status".to_sym
            page.replace_html 'current-status', @new_status
            page.visual_effect :highlight, "#current-status".to_sym 
          end
        end
      end
    end
    
  rescue
    respond_to do |format|
      format.html do
        flash[:notice] = _('Item could not be removed from the recent activities list.')
        redirect_back_or_default @user
      end
      format.js { render(:update){|page| page.alert _("Sorry, item could not be removed from the recent activities list.")}}
    end
  end  

  protected

  def setup
    @user = User.find_by_login(params[:user_id])

    unless is_me?(@user) || is_admin?
      respond_to do |format|
        format.html do
          flash[:notice] = _("Sorry, you can't do that.")
          redirect_back_or_default @user
        end
        format.js { render(:update){|page| page.alert _("Sorry, you can't do that.")}}
      end
    end

  end

end