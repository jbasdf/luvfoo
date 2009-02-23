class Users::SharedEntriesController < ApplicationController

  include UserMethods
  before_filter :get_user 
  before_filter :authorization_required, :only => [:edit, :create, :new]
  before_filter :login_required, :except => [:show]
  before_filter :setup, :only => [:show, :edit, :destroy]

  def show
    @can_edit = (@user.id == current_user.id)

    if !@entry.google_doc
      redirect_to @entry.permalink
      return
    end

    if @entry.is_presentation
      render :template => 'users/shared_entries/presentation'
      return
    end

    @html = @entry.html
    if @html == nil
      redirect_to edit_user_entry_path(@user, @entry)
      return
    end

    render :layout => 'google_docs'
  end

  def new
    @group_id = (params[:group_id] || -1).to_i    
    @entry = Entry.new
    @entry.permalink = params[:u]
    @entry.body = params[:c] || ''
    @entry.body += video_include_text(@entry.permalink)
    @entry.title = params[:t]
    @entry.title = @entry.title[0,@entry.title.rindex(' -')] if @entry.title && @entry.title.index(' - Google Doc')
    @groups = current_user.groups
    @friends = current_user.friends + current_user.followers
  end

  def create
    @entry = current_user.entries.build(params[:entry])

    respond_to do |format|
      if @entry.save

        @friend_ids = (params[:friend_ids] || Array.new)
        @friend_ids.store(current_user.id,"1") if params[:dashboard] == 'on'
        @entry.share_with_friends(current_user, @friend_ids, params[:share_to_edit] == 'on', params[:profile] == 'on') if !@friend_ids.empty?

        @group_ids = params[:group_ids] || Hash.new
        @entry.share_with_groups(current_user, @group_ids) if !@group_ids.empty?

        format.html do
          flash[:notice] = _('Web page was shared')
          if params[:bookmarklet] == true
            redirect_to @entry.permalink
          else
            redirect_to user_path(current_user)
          end
        end
      else
        format.html do
          flash.now[:error] = _('Failed to share the web page.')
          render :action => :new
        end
      end
    end
  end

  def edit
    if !@entry.google_doc || request.user_agent.downcase.index("msie") || @entry.is_presentation
      redirect_to @entry.permalink
      return
    end
    render
  end

  def destroy
    if @shared_entry.destination_id == current_user.id
      @shared_entry.destroy 
      respond_to do |format|
        format.html do
          flash[:notice] = _('Deleted shared entry')
          redirect_to user_path(current_user)
        end
        format.js { render(:update){|page| page.visual_effect :fade, "shared_entry_#{params[:id]}".to_sym}}
      end
    end
  end

  def setup
    @shared_entry = SharedEntry.find(params[:id], :include => 'entry')
    @entry = @shared_entry.entry
  end

  private

  def video_include_text url
    return '' if url == nil || url.empty?
    if url.match(/video\.google\.com/)
      return "[googlevideo: #{url}]"
    elsif url.match(/youtube\.com/)
      return "[youtube: #{url}]"
    end
    return ''
  end    
end
