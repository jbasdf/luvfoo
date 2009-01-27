# == Schema Information
# Schema version: 20090123074335
#
# Table name: comments
#
#  id               :integer(4)    not null, primary key
#  comment          :text          
#  created_at       :datetime      not null
#  updated_at       :datetime      not null
#  user_id          :integer(4)    
#  commentable_type :string(255)   default(""), not null
#  commentable_id   :integer(4)    not null
#  is_denied        :integer(4)    default(0), not null
#  is_reviewed      :boolean(1)    
#

class Comment < ActiveRecord::Base

  include SecureMethods

  validates_presence_of :comment, :user

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  belongs_to :group

  # named_scopes
  named_scope :recent, :order => 'created_at DESC'

  def after_create
    if commentable.respond_to?(:feed_to)
      feed_item = FeedItem.create(:item => self, :creator_id => self.user_id)
      (commentable.feed_to).each{ |u| u.feed_items << feed_item }
    end
  end

  def self.between_users user1, user2
    find(:all, {
      :order => 'created_at asc',
      :conditions => [
        "(user_id=? and commentable_id=?) or (user_id=? and commentable_id=?) and commentable_type='User'",
        user1.id, user2.id, user2.id, user1.id]
        })
  end

  def can_edit?(user)

    return true if check_user(user)

    case self.commentable_type
    when 'User'
      return commentable_id == user.id
    when 'NewsItem'
      if commentable.newsable.is_a?(User)
        return self.commentable.newsable.id == user.id
      elsif commentable.newsable.is_a?(Group)
        return self.commentable.newsable.can_edit?(user)
      elsif commentable.newsable.is_a?(Site) || commentable.newsable.is_a?(Widget)
        return false # let is_admin? pick this up
      else
        raise 'Unknow news item type:' + commentable.newsable.class
      end

    when 'Group'
      return self.commentable.can_edit?(user)
    end

    return false

  end

end
