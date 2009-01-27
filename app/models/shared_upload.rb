# == Schema Information
# Schema version: 20090123074335
#
# Table name: shared_uploads
#
#  id                     :integer(4)    not null, primary key
#  shared_uploadable_id   :integer(4)    
#  shared_uploadable_type :string(255)   
#  upload_id              :integer(4)    
#  shared_by_id           :integer(4)    
#  created_at             :datetime      
#  updated_at             :datetime      
#

class SharedUpload < ActiveRecord::Base

  include SecureMethods

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  belongs_to :upload
  belongs_to :shared_uploadable, :polymorphic => true
  belongs_to :shared_by, :class_name => 'User', :foreign_key => 'shared_by_id'

  validates_presence_of :shared_uploadable_id, :upload_id, :shared_by_id

  def after_create
    feed_item = FeedItem.create(:item => self, :creator_id => self.shared_by_id)
    if shared_uploadable.is_a?(Group) && shared_uploadable.respond_to?(:feed_to)
      (shared_uploadable.feed_to).each{ |u| u.feed_items << feed_item }
    elsif shared_uploadable.is_a?(User)
      ([shared_uploadable, self.shared_by]).each{ |u| u.feed_items << feed_item }
    end
  end

  def can_edit?(user)
    shared_uploadable.id == user.id || check_sharer(user)
  end

end
