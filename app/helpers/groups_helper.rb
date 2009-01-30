module GroupsHelper

  def can_participate?
    @can_participate == true
  end

  def member?
    return false if @group.nil?
    user = @user || current_user
    @group.is_member?(user) || is_admin?
  end

  def manager?
    return false if @group.nil?
    user = @user || current_user
    @group.can_edit?(user)
  end

  def notice_message(message)
    if message && message.length > 0
      '<div class="notice">' + sanitize(message) + '</div>'
    end
  end

end
