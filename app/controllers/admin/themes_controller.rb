class Admin::ThemesController < Admin::BaseController

  # this controller handles site wide settings

  before_filter :login_required
  before_filter :get_site
  cache_sweeper :site_sweeper, :only => [:update]

  def edit
    @current_theme, @themes = Site.available_themes(@site)
    respond_to do |format|
      format.html
    end
  end

  def update
    @site.update_attributes!(params[:site])
    refresh_current_theme
    respond_to do |format|
      flash[:notice] = 'Theme was successfully updated.'
      format.html { redirect_to edit_admin_theme_path }
      format.xml { head :ok }
    end
  end

  private

  def get_site
    @site = Site.first
  end

end