class Admin::ThemesController < Admin::BaseController

  # this controller handles site wide settings

  before_filter :login_required
  before_filter :get_site
  cache_sweeper :site_sweeper, :only => [:update]

  def edit
    get_themes
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

  def get_themes
    @themes = []
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
        @themes << theme
        @current_theme = theme if @site.theme == theme_name

      end
	end
  end

  def get_site
    @site = Site.first
  end

end