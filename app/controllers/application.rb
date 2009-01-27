require 'gettext/rails'
class ApplicationController < ActionController::Base
  layout 'application'

  helper :all

  before_init_gettext :default_locale
  init_gettext "luvfoo"
  init_gettext "beast" if Object.const_defined?(:GetText)

  #include ExceptionNotifiable
  include AuthenticatedSystem

  filter_parameter_logging "password"

  helper_method :last_active
  
  before_filter :login_from_cookie, :setup_paging, :set_locale_from_param
  after_filter :store_location

  def default_locale
    if (cookies["lang"].nil? or cookies["lang"].empty?)
      set_locale GlobalConfig.default_locale
    else
      set_locale cookies["lang"]
    end
  end

  def set_locale_from_param
    if params[:lang]
      cookies["lang"] = params[:lang]
      set_locale params[:lang]
    end
  end

  def last_active
    session[:last_active] ||= Time.now.utc
  end
  
  def setup_paging
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @per_page = (params[:per_page] || (RAILS_ENV=='test' ? 1 : 40)).to_i
  end
  
  def autocomplete_urls_json(items, root_part)
    return '' if items.nil?
    items.collect{|item| { :title => item.title, :url_key => root_part + (item.url_key || '') } }.to_json
  end
  
  helper_method :flickr, :flickr_images
  # API objects that get built once per request
  def flickr(user_name = nil, tags = nil )
    @flickr_object ||= Flickr.new(GlobalConfig.flickr_cache, GlobalConfig.flickr_key, GlobalConfig.flickr_secret)
  end

  def flickr_images(user_name = "", tags = "")
    unless RAILS_ENV == "test"# || RAILS_ENV == "development"
      begin
        flickr.photos.search(user_name.blank? ? nil : user_name, tags.blank? ? nil : tags , nil, nil, nil, nil, nil, nil, nil, nil, 20)
      rescue
        nil
      rescue Timeout::Error
        nil
      end
    end
  end

  def rescue_action_in_public(exception)
    case exception
      when ActiveRecord::RecordNotFound, ActionController::UnknownController, ActionController::UnknownAction
        error_page = File.join(RAILS_ROOT, 'locale', locale.to_s.downcase.gsub('_','-'), '404.html')
      else
        error_page = File.join(RAILS_ROOT, 'locale', locale.to_s.downcase.gsub('_','-'), '500.html')
    end
    if File.exists?(error_page)
      render :file => error_page
    else
      super
    end
  end

#  uncomment this and set config.action_controller.consider_all_requests_local = false
#  in config/environments/development.rb to get the app to behave like it is in development mode
#  def local_request?
#    false
#  end

end

