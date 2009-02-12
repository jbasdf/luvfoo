# == Schema Information
# Schema version: 20090123074335
#
# Table name: news_items
#
#  id            :integer(4)    not null, primary key
#  title         :string(255)   
#  body          :text          
#  newsable_id   :integer(4)    
#  newsable_type :string(255)   
#  created_at    :datetime      
#  updated_at    :datetime      
#  url_key       :string(255)   
#  icon          :string(255)   
#  creator_id    :integer(4)    
#

class NewsItem < ActiveRecord::Base

  include SecureMethods

  has_permalink :title, :url_key

  acts_as_taggable_on :tags

  belongs_to :newsable, :polymorphic => true
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'   

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'
  has_many :photos, :as => :photoable, :order => 'created_at desc'

  validates_presence_of :title, :body

  file_column :icon, :magick => {
    :versions => { 
      :bigger => {:crop => "1:1", :size => "250x250", :name => "bigger"},
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

  acts_as_solr :fields => [ :content_p, :newsable_type ]

  before_save :whitelist_attributes
  
  def after_create
    if newsable.respond_to?(:feed_to)
      feed_item = FeedItem.create(:item => self, :creator_id => creator_id)
      (newsable.feed_to).each{ |u| u.feed_items << feed_item }
    end
  end
  
  def content_p
    "#{title} #{body} #{tags.collect{|t| t.name}.join(' ')}"
  end

  def content_u
    content_p
  end

  def content_a
    content_p
  end

  def to_param
    url_key || id
  end

  def self.latest_news_from(rolename = 'administrator', limit = 4)
    role = Role.find(:first, :include => 'users', :conditions => ["rolename = ?", rolename])
    if role && role.users.length > 0
      user_ids = role.users.collect{|u| u.id}.join(',')
      NewsItem.find(:all, :conditions => "newsable_type = 'User' AND newsable_id IN (#{user_ids})", :limit => limit, :order => 'created_at desc')
    else
      NewsItem.find(:all , :limit => limit, :order => 'created_at desc')
    end
  end

  def can_edit?(user)
    check_creator(user)
  end
  
  def video
    ""
  end
  
  def video= url
    if !url.empty?
      body << (_('[youtube: %{video_address}]') % {:video_address => url}) if /^http:\/\/www.youtube/.match( url )
      body << (_('[googlevideo: %{video_address}]') % {:video_address => url}) if /^http:\/\/video.google/.match( url )
    end
  end

  protected
  
  def whitelist_attributes
    # let admins throw in whatever they want TODO decide if this is a good or bad idea
    #if !self.creator.is_admin?
      self.title = white_list(self.title)
      self.body = white_list(self.body)
    #end
  end
  
end
