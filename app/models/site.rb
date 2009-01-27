# == Schema Information
# Schema version: 20090123074335
#
# Table name: sites
#
#  id                           :integer(4)    not null, primary key
#  name                         :string(255)   
#  created_at                   :datetime      
#  updated_at                   :datetime      
#  title                        :string(255)   default(""), not null
#  subtitle                     :string(255)   default(""), not null
#  slogan                       :string(255)   default(""), not null
#  background_color             :string(255)   default(""), not null
#  font_color                   :string(255)   default(""), not null
#  font_style                   :string(255)   default(""), not null
#  font_size                    :string(255)   default(""), not null
#  content_background_color     :string(255)   default(""), not null
#  a_font_style                 :string(255)   default(""), not null
#  a_font_color                 :string(255)   default(""), not null
#  top_background_color         :string(255)   default(""), not null
#  top_color                    :string(255)   default(""), not null
#  link_button_background_color :string(255)   
#  link_button_font_color       :string(255)   
#  highlight_color              :string(255)   
#

class Site < ActiveRecord::Base

  has_many :news_items, :as => :newsable
  has_many :pages, :as => :contentable, :class_name => 'ContentPage'
  has_many :uploads, :as => :uploadable
  
  has_one :logo, :dependent => :destroy 
  
end
