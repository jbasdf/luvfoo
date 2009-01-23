class EventUsersController < ApplicationController

  skip_filter :store_location
  before_filter :login_required

  def create

    @event = Event.find(params[:event_id])
    @event_user = EventUser.new
    @event_user.event = @event
    @event_user.user = current_user
    @event_user.save!
    
    respond_to do |format|
      format.js do
        render :update do |page|
          page << "jQuery('#attend_'" + @event.dom_id + ").val('" + _('You are attending') + "');"
          page << "jQuery('#attendees_for_'" + @event.dom_id + ").val('" + @event.attendees_count + "');"
        end
      end
    end
  rescue
    format.js do
      render :update do |page|
        page << "message('" + _("Oops... I could not create that comment.  %{errors}") % {:errors => @comment.errors.full_messages.to_sentence } + "');"
      end     
    end
  end

  def destroy

    @event_user.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = _('Comment successfully removed.')
        redirect_back_or_default current_user
      end
      format.js { render(:update){|page| page.visual_effect :puff, "#{@comment.dom_id}".to_sym}}
    end
  end  

end
