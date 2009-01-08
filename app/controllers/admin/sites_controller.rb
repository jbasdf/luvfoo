class Admin::SitesController < Admin::BaseController

  # this controller handles site wide settings

  before_filter :login_required
  before_filter :setup
  cache_sweeper :site_sweeper, :only => [:update]

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update 
    @logo = @site.logo 
    @service = SiteLogoService.new(@site, @logo, current_user) 
    respond_to do |format| 
      if @service.update_attributes(params[:site], params[:logo_file]) 
        flash[:notice] = 'Site was successfully updated.' 
        @logo = @service.logo
        @site = @service.site
        format.html { render :action => :edit } 
        format.xml { head :ok } 
      else 
        @logo = @service.logo
        @site = @service.site
        format.html { render :action => :edit } 
        format.xml { render :xml => @site.errors, :status => :unprocessable_entity } 
      end 
    end 
  end 
  
  private

  def setup
    @site = Site.first
    @logo = @site.logo
  end

end