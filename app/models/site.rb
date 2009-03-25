# == Schema Information
# Schema version: 20090213002439
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
  
  def self.available_themes(site)
     themes = []
     current_theme = {:name => 'default', :preview_image => '/images/no_preview.gif', :description => 'default theme'}
     theme_path = File.join(RAILS_ROOT, 'themes')
     
     Dir.glob("#{theme_path}/*").each do |theme_directory|
       if File.directory?(theme_directory)
         theme_name = File.basename(theme_directory)

         image = Dir.glob(File.join(RAILS_ROOT, 'public', 'images', theme_name, 'preview.*')).first || File.join('/', 'images', 'no_preview.gif')
         image = image.gsub(File.join(RAILS_ROOT, 'public'), '')

         description = ''
         description_file = File.join(theme_directory, 'description.txt')
         if File.exist?(description_file)
           f = File.new(description_file, "r") 
           description = f.read
           f.close
         end

         theme = {:name => theme_name, :preview_image => image, :description => description}
         themes << theme
         
         current_theme = theme if site.theme == theme_name
       end
       
   	 end
   	 
   	 [current_theme, themes]
   end
   
end
