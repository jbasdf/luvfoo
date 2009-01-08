module CommentsHelper

  def x_comment_link comment
    if comment.can_edit?(current_user)
      link_to_remote _("Delete"), :url => comment_path(comment), :method => :delete
    end
  end

end
