module PageMethods
   
    protected
            
    # limit search to only pages the belong to the site
    def get_site_content_page
      @content_page = @site.pages.find_by_url_key(params[:id]) || @site.pages.find(params[:id])
    end

    def get_site
      @site = Site.first
    end
    
end
