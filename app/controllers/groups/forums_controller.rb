class Groups::ForumsController < ApplicationController

  include ForumMethods
  include GroupMethods

  before_filter :get_group
  before_filter :find_forum
  
  def index
    redirect_to group_forum_path(@group, @group.forums.first)
  end
  
  def show
    respond_to do |format|
      format.html do
        setup_show_forum
      end
      format.xml { render :xml => @forum }
    end
  end
  
end