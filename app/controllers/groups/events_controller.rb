class Groups::EventsController < ApplicationController

  include UserMethods
  include GroupMethods
  include EventMethods

  before_filter :login_required, :except => [:index, :show]
  before_filter :get_user
  before_filter :get_group
  before_filter :authorization_required, :only => [:new, :edit, :create, :update, :destroy] 
  before_filter :get_event, :except => [:new, :create, :index]

  cache_sweeper :group_events_sweeper, :only => [:update, :create, :destroy]

  #caches_page :index 
                
  def index
    @events = @group.events.paginate(:page => @page, :per_page => @per_page)
    
    respond_to do |format|
      format.html do
        @user_events = EventUser.current_events_for(current_user)
        render
      end
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

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
      format.ics do
        ics_event = Icalendar::Event.new
        ics_event.start = @event.start_at.strftime("%Y%m%dT%H%M%S")
        if @event.end_at
          ics_event.end = @event.end_at.strftime("%Y%m%dT%H%M%S")
        else
          ics_event.end = @event.start
        end
        ics_event.summary = @event.summary
        ics_event.description = @event.description
        ics_event.location = @event.location
        @calendar.add ics_event
        @calendar.publish
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render_without_layout :text => @calendar.to_ical
      end
    end
  end

  def new
    @event = Event.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end
  
  def create
    @event = @group.events.build(params[:event])
    @event.user = current_user
    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(group_events_path(@group)) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
    end
  end
  
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(group_events_path(@group)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @event.destroy
    flash[:notice] = "Event '#{@event.title}' was successfully deleted."
    respond_to do |format|
      format.html { redirect_to(group_events_path(@group)) }
      format.xml  { head :ok }
    end
  end
  
private

  def permission_denied 
    flash[:error] = _("You don't have permission manage the events for this group.")     
    respond_to do |format|
      format.html do
        redirect_to group_events_path(@group)
      end
    end
  end
  
end