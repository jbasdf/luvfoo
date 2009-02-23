class Groups::SharedEntriesController < ApplicationController

  include GroupMethods

  before_filter :login_required, :except => [:index, :show]
  before_filter :get_group, :only => [:show]

  def index
    render
  end

  def show

    @shared_entry = SharedEntry.find(params[:id], :include => 'entry')
    @entry = @shared_entry.entry

    if !@entry.google_doc
      redirect_to @entry.permalink
      return
    end

    if @entry.is_presentation
      render :template => 'groups/shared_entries/presentation'
      return
    end

    @html = @entry.html
    if @html == nil
      render :text => _('Unable to display document.')
      return
    end

    render :layout => 'google_docs'
  end

end
