class CommentsController < ApplicationController

  skip_filter :store_location
  before_filter :login_required
  before_filter :get_parent, :only => [:create]
  before_filter :get_comment, :only => [:destroy]

  def create

    @comment = @parent.comments.build(params[:comment].merge(:user_id => current_user.id))

    respond_to do |format|
      if @comment.save
        format.js do
          render :update do |page|
            page.insert_html :top, "#{dom_id(@parent)}_comments", :partial => 'comments/comment'
            page.visual_effect :highlight, "comment_#{@comment.id}".to_sym
            page << 'tb_remove();'
            page << "jQuery('#comment_comment').val('');"
          end
        end
      else
        format.js do
          render :update do |page|
            page << "message('" + _("Oops... I could not create that comment.  %{errors}") % {:errors => @comment.errors.full_messages.to_sentence } + "');"
          end
        end
      end
    end

  end

  def destroy

    @comment.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = _('Comment successfully removed.')
        redirect_back_or_default current_user
      end
      format.js { render(:update){|page| page.visual_effect :puff, "#{@comment.dom_id}".to_sym}}
    end
  end  

  protected

  def get_parent
    if !params[:type] || !params[:id]
      raise 'Please specify a parent object via type and id'
      return
    end

    case params[:type]
    when 'User'
      @parent = User.find(params[:id])
    when 'NewsItem'
      @parent = NewsItem.find(params[:id])
    when 'Group'
      @parent = Group.find(params[:id])
      # if the current_user isn't a member of the group they can't make comments
      unless @parent.is_member?(current_user) || is_admin?
        respond_to do |format|
          format.js do
            render :update do |page|
              page << "message('" + _("Sorry, only group members can create comments") + "');"
            end
          end
        end
        return
      end
    end
  end

  def get_comment

    @comment = Comment.find(params[:id])

    unless @comment.can_edit?(current_user) || is_admin?
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
