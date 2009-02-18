class ContentController < ApplicationController

  before_filter :login_required, :only => [:show_protected_page]  

  def show_page
    render_page('pages')
  end

  def show_protected_page
    render_page('protected-pages')
  end


  protected

  def render_page page_path
    page_locale = locale || params[:locale] || params[:language] || "en_US"
    url_key = params[:content_page].join('/')
    content_page = "#{RAILS_ROOT}/content/#{page_path}/#{page_locale}/#{url_key}.html"
    render :file => content_page, :layout => true
  rescue
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
  end  

  # add this if we ever want to let users edit the pages on the disk through the web interface
  # def update_template(type, owner_id)
  #     content_file_dir = File.join(RAILS_ROOT, 'app', 'views', 'page', type, owner_id, locale.to_s) if type == "user"
  #     content_file_dir = File.join(RAILS_ROOT, 'app', 'views', 'page', type, locale.to_s) if type == "site"
  #     file_name = self.url_key
  #     index = file_name.rindex '/'
  #     if !index.nil?
  #       content_file_dir = File.join(content_file_dir, file_name[0, index])
  #       file_name = file_name[index, file_name.length]
  #     end
  # 
  #     #puts '********************' + content_file_dir
  # 
  #     FileUtils.mkdir_p content_file_dir  
  # 
  #     content_file_path = File.join(content_file_dir, file_name)
  #     File.open(content_file_path + '.html', 'w') do |content_file|  
  #       content_file.puts self.body  
  #     end 
  #   end
  
end
