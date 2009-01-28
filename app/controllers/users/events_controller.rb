class Users::EventsController < ApplicationController

  include UserMethods
  include EventMethods

  before_filter :login_required
  before_filter :get_user
                
  def index
    @events = @user.attending_events.paginate(:page => @page, :per_page => @per_page)    
    respond_to do |format|
      format.ics do
        # require 'icalendar'
        @calendar = Icalendar::Calendar.new
        @events.each do |event|
          ics_event = Icalendar::Event.new
          ics_event.start = event.start_at.strftime("%Y%m%dT%H%M%S")
          if event.end_at
            ics_event.end = event.end_at.strftime("%Y%m%dT%H%M%S")
          else
            ics_event.end = event.start
          end
          ics_event.summary = event.summary
          ics_event.description = event.description
          ics_event.location = event.location
          @calendar.add ics_event
        end
        @calendar.publish
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render :layout => false, :text => @calendar.to_ical
      end      
    end
  end
  
end