class Users::StatusUpdatesController < ApplicationController

  include UserMethods

  skip_filter :store_location
  before_filter :login_required
  before_filter :get_user
  before_filter :get_status_update, :only => [:destroy]

  def create

    @status_update = @user.status_updates.build(params[:status_update])
    @status_update.text.gsub!(@user.short_name, '')
    @status_update.save!
    @new_activity = render_to_string(:partial => 'feed_items/status_update', :locals => {:status_update => @status_update})
    @new_status = render_to_string(:partial => 'users/current_status', :locals => {:user => @user})
    
    respond_to do |format|
      format.html do
        redirect_to user_path(@user)
      end
      format.js do
        render :update do |page|
          page.insert_html :top, 'activity_feed', @new_activity
          page.replace_html 'current-status', @new_status          
          page.visual_effect :highlight, "#{@status_update.dom_id}".to_sym         
      		page << 'jQuery("#status_update").val(\'' + _("What are you doing right now?") + '\');'
      		page << "jQuery('#status-update-field').removeClass('status-update-lit');"
      		page << "jQuery('#status-update-field').addClass('status-update-dim');" 
      		page << 'jQuery("#status-update-field").show();'
      	  page << 'jQuery("#submit_status").show();'
      	  page << 'jQuery("#progress-bar").hide();'
      	  page << 'apply_delete();'   		      		
        end
      end
    end
    
  rescue => ex
    message = _("Oops... There was a problem updating your status.  %{errors}") % {:errors => @status_update.errors.full_messages.to_sentence }
    respond_to do |format|
      format.html do
        flash[:error] = message
        redirect_to user_path(@user)
      end
      format.js do
        render :update do |page|
          page << "message('" + message + "');"
        end
      end
    end

  end

  def destroy

    @status_update.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = _('Status update successfully removed.')
        redirect_back_or_default current_user
      end
      format.js do
        @new_status = render_to_string(:partial => 'users/current_status', :locals => {:user => @user})
        render(:update) do |page|
          page.visual_effect :puff, "#{@status_update.dom_id}".to_sym
          page.visual_effect :puff, "#current-status".to_sym
          page.replace_html 'current-status', @new_status
          page.visual_effect :highlight, "#current-status".to_sym          
        end
      end
    end
  end

  def get_status_update

    @status_update = StatusUpdate.find(params[:id])

    unless @status_update.can_edit?(current_user)
      respond_to do |format|
        format.html do
          flash[:notice] = _("Sorry, you can't do that.")
          redirect_back_or_default current_user
        end
        format.js { render(:update){|page| page.alert _("Sorry, you can't do that.")}}
      end
    end

  end
  
end
