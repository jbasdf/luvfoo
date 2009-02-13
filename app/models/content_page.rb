class ContentPage < ActiveRecord::Base
    
  include SecureMethods
  
  acts_as_versioned :limit => 100
  acts_as_taggable_on :tags, :menus
  
  has_permalink :title, :url_key, :scope => :contentable_id
  
  validates_presence_of :title 
  validates_presence_of :body_raw
  validates_presence_of :creator

  belongs_to :contentable, :polymorphic => true
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'

  before_save :whitelist_attributes

  named_scope :by_newest, :order => "created_at DESC"
  named_scope :by_alpha, :order => "title ASC"
  named_scope :by_parent, lambda { |parent_id| { :conditions => ['parent_id = ?', parent_id || 0] } }
  
  acts_as_solr :fields => [ :content_p, :content_u, :content_a ]
  
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

  def can_edit?(user)
    check_creator(user)
  end
  
  def permalink=(val)
    update_attribute(:url_key, PermalinkFu.escape(val))
  end
  
  # use to generate json
  def json_hash
    if children.size > 0
      children.collect { |node| { node.name => node.json_hash }.to_json }
    else
      { node.name => node.products.find(:all).collect(&:name) }.to_json
    end
  end  
  
  protected
  
  def whitelist_attributes
    # let users throw in whatever they want TODO decide if this is a good or bad idea
    self.body = self.body_raw
    if self.creator.is_admin?
      #self.body = self.body_raw
    else
      self.title = white_list(self.title)
      #self.body = white_list(self.body_raw)
    end
  end

end
