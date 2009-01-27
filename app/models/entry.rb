# == Schema Information
# Schema version: 20090123074335
#
# Table name: entries
#
#  id           :integer(4)    not null, primary key
#  permalink    :string(2083)  
#  title        :string(255)   
#  body         :text          
#  published_at :datetime      
#  created_at   :datetime      
#  updated_at   :datetime      
#  user_id      :integer(4)    
#  google_doc   :boolean(1)    
#  displayable  :boolean(1)    
#

class Entry < ActiveRecord::Base

  include GoogleDocs

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'    
  validates_presence_of :title, :permalink
  belongs_to :user
  has_many :shared_entries

  def share_with_friend(sharer, friend_id, can_edit = false, show_on_profile = false)
    friend = User.find(friend_id)
    sharing_to_self = sharer.id == friend_id
    shared_entry = friend.shared_entries.build(:shared_by_id => sharer.id, :entry_id => self.id, 
    :can_edit => can_edit || sharing_to_self, :public => (show_on_profile == true && sharing_to_self))
    shared_entry.save!

    feed_item = FeedItem.create(:item => shared_entry, :creator_id => sharer.id)        
    friend.feed_items << feed_item
    shared_entry
  end

  def share_with_group(sharer, group_id)
    group = Group.find(group_id)
    if group.is_member?(sharer)
      shared_entry = group.shared_entries.build(:shared_by_id => sharer.id, :entry_id => self.id, :public => true)
      shared_entry.save!
    end

    # Feed to group members
    feed_item = FeedItem.create(:item => shared_entry, :creator_id => sharer.id)
    (group.feed_to).each{ |u| u.feed_items << feed_item }
    shared_entry
  end

  def permalink= val
    if val != nil
      if is_google_doc(val)
        self.google_doc = true
        self.displayable = is_published(val)
      end
    end
    write_attribute(:permalink, val)
  end

  def html
    get_html(self.permalink)
  end

  def google_doc_id
    get_doc_id(self.permalink)
  end

  def is_presentation
    PRESENTATION == get_document_type(self.permalink) 
  end

  def share_with_friends(user, friend_ids, can_edit, show_on_profile)
    friend_ids.each do |friend_id, checked|
      self.share_with_friend(user, friend_id, can_edit, show_on_profile) if (checked == "1")
    end    
  end

  def share_with_groups(user, group_ids)
    group_ids.each do |group_id, checked|
      self.share_with_group(user, group_id) if (checked == "1")
    end    
  end
end
