class EventUsersController < ApplicationController

  skip_filter :store_location
  before_filter :login_required

  def create
    @event = Event.find(params[:event_id])
    @event_user = EventUser.new
    @event_user.event = @event
    @event_user.user = current_user
    @event_user.save!
    @event.reload
    respond_to do |format|
      format.html do
        redirect_back_or_default current_user
      end
      format.js do
        render :update do |page|  
          page.replace_html "attend_#{@event.dom_id}", :partial => 'events/not_attending', :locals => {:event => @event, :event_user => @event_user}
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => ex
    format.js do
      render :update do |page|
        page << "message('" + _("I was unable to add you to the event.  %{errors}") % {:errors => @event_user.errors.full_messages.to_sentence } + "');"
      end     
    end
  end

  def destroy
    @event_user = EventUser.find(params[:id])
    @event = @event_user.event
    @event_user.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = message
        redirect_back_or_default current_user
      end
      format.js do
        render :update do |page|
          page.replace_html "attend_#{@event.dom_id}", :partial => 'events/attending', :locals => {:event => @event}
        end
      end
    end
  end  

end
