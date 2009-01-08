class SiteLogoService 
  
  attr_reader :site, :logo 
  
  def initialize(site, logo, user) 
    @site = site 
    @logo = logo 
    @user = user
  end 
  
  def save 
    return false unless valid? 
    begin 
      Site.transaction do 
        if @logo && @logo.new_record? 
          @site.logo.destroy if @site.logo 
          @logo.site = @site 
          @logo.save!
        end 
        @site.save!
        true 
      end 
    rescue 
      false 
    end 
  end 
  
  def update_attributes(site_attributes, logo_file) 
    @site.attributes = site_attributes 
    unless logo_file.blank? 
      @logo = Logo.new(:uploaded_data => logo_file) 
      @logo.user = @user
    end 
    save 
  end

  def valid? 
    if @logo
      @site.valid? && @logo.valid? 
    else
      @site.valid?
    end    
  end 
  
end