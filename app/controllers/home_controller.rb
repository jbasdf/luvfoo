class HomeController < ApplicationController
  
  layout 'application'
  
  include PageMethods

  skip_filter :store_location, :only => [:home]
  before_filter :login_required, :only => [:me]	
  before_filter :get_site
  
  def index
    render :layout => false
  end

  def home
    @content_page = @site.pages.find_by_url_key('home')
    respond_to do |format|
      format.html {render :layout => 'home'}
      format.rss {render :partial =>  'profiles/newest_member', :collection => new_members}
    end
  end

  def contact
    return unless request.post?
    body = []
    params.each_pair { |k,v| body << "#{k}: #{v}"  }
    HomeMailer.deliver_mail(:subject=>_("from %{application_name} contact page") % {:application_name => GlobalConfig.application_name}, :body=>body.join("\n"))
    flash[:notice] = _("Thank you for your message.  A member of our team will respond to you shortly.")
    redirect_to contact_url    
  end

  def newest_members
    respond_to do |format|
      format.html {render :action=>'index'}
      format.rss {render :layout=>false}
    end
  end
  
  def latest_comments
    respond_to do |format|
      format.html {render :action=>'index'}
      format.rss {render :layout=>false}
    end
  end

  def me
    redirect_to current_user
  end

  def sitemap
    respond_to do |format|
      format.html { render }
    end
  end

  def offline
    render :layout => false
  end
  
  private

  def allow_to 
    super :all, :all=>true
  end

end


class HomeMailer < ActionMailer::Base
  def mail(options)
    self.generic_mailer(options)
  end
end
