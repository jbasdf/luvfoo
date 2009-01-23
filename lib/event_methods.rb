module EventMethods

  protected

  def get_event
    @event = Event.find(params[:id])
  end

end