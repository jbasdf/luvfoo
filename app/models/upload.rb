# == Schema Information
# Schema version: 20090123074335
#
# Table name: uploads
#
#  id              :integer(4)    not null, primary key
#  parent_id       :integer(4)    
#  user_id         :integer(4)    
#  content_type    :string(255)   
#  name            :string(255)   
#  caption         :string(1000)  
#  description     :text          
#  filename        :string(255)   
#  thumbnail       :string(255)   
#  size            :integer(4)    
#  width           :integer(4)    
#  height          :integer(4)    
#  created_at      :datetime      
#  updated_at      :datetime      
#  is_public       :boolean(1)    default(TRUE)
#  uploadable_id   :integer(4)    
#  uploadable_type :string(255)   
#

require 'mime_type_groups'

class Upload < ActiveRecord::Base

  include SecureMethods

  belongs_to :uploadable, :polymorphic => true

  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  belongs_to :user
  has_many :shared_uploads, :dependent => :destroy

  #    has_one :user_as_avatar, :class_name => "User", :foreign_key => "avatar_id"

  has_attachment GlobalConfig.prepare_options_for_attachment_fu(GlobalConfig.upload['attachment_fu_options'])
  validates_as_attachment

  acts_as_taggable

  validates_presence_of :size
  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :user, :if => Proc.new{|record| record.parent.nil? }
  validates_inclusion_of :content_type, :in => attachment_options[:content_type], :message => "is not allowed", :allow_nil => true if attachment_options[:content_type]
  validates_inclusion_of :size, :in => attachment_options[:size], :message => " is too large", :allow_nil => true if attachment_options[:size]

  attr_protected :user_id, :uploadable_id, :uploadable_type
  
  #Named scopes
  named_scope :newest_first, :order => "created_at DESC"
  named_scope :alphabetic, :order => "filename DESC"
  named_scope :recent, :order => "created_at DESC", :conditions => ["parent_id IS NULL AND is_public = true"]
  named_scope :new_this_week, :order => "created_at DESC", :conditions => ["created_at > ? AND parent_id IS NULL AND is_public = true", 7.days.ago.to_s(:db)]
  named_scope :tagged_with, lambda {|tag_name|
    {:conditions => ["is_public = true AND tags.name = ?", tag_name], :include => :tags}
  }
  named_scope :images, :conditions => "content_type IN (#{MimeTypeGroups::IMAGE_TYPES.collect{|type| "'#{type}'"}.join(',')})"
  named_scope :public, :conditions => 'is_public = true'
  named_scope :documents, :conditions => "content_type IN (#{(MimeTypeGroups::WORD_TYPES + MimeTypeGroups::EXCEL_TYPES + MimeTypeGroups::PDF_TYPES).collect{|type| "'#{type}'"}.join(',')})" 
  named_scope :files, :conditions => "content_type NOT IN (#{MimeTypeGroups::IMAGE_TYPES.collect{|type| "'#{type}'"}.join(',')})"
  
  def after_create
    if uploadable.is_a?(Group) && uploadable.respond_to?(:feed_to)
      feed_item = FeedItem.create(:item => self, :creator_id => self.user_id)
      (uploadable.feed_to).each{ |u| u.feed_items << feed_item }
    end
  end
     
  def owner
    self.user
  end

  def max_upload_size
    GlobalConfig.upload['attachment_fu_options']['max_size']
  end

  def self.find_recent(options = { :limit => 3 })
    self.new_this_week.find(:all, :limit => options[:limit])
  end

  def is_image?
    MimeTypeGroups::IMAGE_TYPES.include?(self.content_type)
  end

  def is_mp3?
    MimeTypeGroups::MP3_TYPES.include?(self.content_type)
  end

  def is_excel?
    MimeTypeGroups::EXCEL_TYPES.include?(self.content_type)
  end

  def is_pdf?
    MimeTypeGroups::PDF_TYPES.include?(self.content_type)
  end

  def is_word?
    MimeTypeGroups::WORD_TYPES.include?(self.content_type)
  end

  def is_text?
    MimeTypeGroups::TEXT_TYPES.include?(self.content_type)
  end
  
  def upload_type
    if self.is_pdf?
      'Adobe pdf file'
    elsif self.is_word?
      'Word document'
    elsif self.is_image?
      'photo'
    elsif self.is_mp3?
      'mp3'
    elsif self.is_excel?
      'Excel document'
    elsif self.is_text?
      'text file'
    else
      'file'
    end
  end
  
  def icon
    if self.is_pdf?
      '/images/file_icons/pdf.gif'
    elsif self.is_word?
      '/images/file_icons/word.png'
    elsif self.is_image?
      self.public_filename(:icon)
    elsif self.is_mp3?
      '/images/file_icons/mp3.png'
    elsif self.is_excel?
      '/images/file_icons/excel.png'
    elsif self.is_text?
      '/images/file_icons/text.png'
    else
      '/images/blurp_file.png'
    end
  end

  def share_with_friend(sharer, friend_id)
    friend = User.find(friend_id)
    friend.shared_uploads.find_or_create_by_upload_id_and_shared_by_id(self.id, sharer.id)
  end

  def share_with_group(sharer, group_id)
    group = Group.find(group_id)
    if group.is_member?(sharer)
      shared_upload = group.shared_uploads.find_or_create_by_upload_id_and_shared_by_id(self.id, sharer.id)
    end
    # TODO decide if we want to feed this into a feed somewhere
    shared_upload
  end

  def share_with_friends(user, friend_ids)
    friend_ids.each do |friend_id, checked|
      self.share_with_friend(user, friend_id) if (checked == "1")
    end    
  end

  def share_with_groups(user, group_ids)
    group_ids.each do |group_id, checked|
      self.share_with_group(user, group_id) if (checked == "1")
    end    
  end

  def can_edit?(user)
    return false if user.nil?
    check_user(user)
  end    
end
