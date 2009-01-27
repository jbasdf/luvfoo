# == Schema Information
# Schema version: 20090123074335
#
# Table name: photos
#
#  id             :integer(4)    not null, primary key
#  caption        :string(1000)  
#  created_at     :datetime      
#  updated_at     :datetime      
#  photoable_id   :integer(4)    
#  image          :string(255)   
#  photoable_type :string(255)   
#  creator_id     :integer(4)    
#

# == Schema Information
# Schema version: 20081125042115
#
# Table name: photos
#
#  id             :integer(4)    not null, primary key
#  caption        :string(1000)  
#  created_at     :datetime      
#  updated_at     :datetime      
#  photoable_id   :integer(4)    
#  image          :string(255)   
#  photoable_type :string(255)   
#

class Photo < ActiveRecord::Base

  include SecureMethods

  belongs_to :photoable, :polymorphic => true

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'

  belongs_to :user
  belongs_to :group
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id' 

  validates_presence_of :image

  file_column :image, :magick => {
    :versions => { 
      :square => {:crop => "1:1", :size => "50x50", :name => "square"},
      :small => "175x250"
    }
  }

  acts_as_solr :fields => [ :content_p, :content_u, :content_a ]

  def after_create
    if photoable.respond_to?(:feed_to)
      feed_item = FeedItem.create(:item => self)
      (photoable.feed_to).each{ |u| u.feed_items << feed_item }
    end
  end
  
  def content_p
    caption
  end

  def content_u
    content_p
  end

  def content_a
    content_p
  end

  def can_edit?(user)
    return false if user.nil?
    check_user(user)
  end

end
