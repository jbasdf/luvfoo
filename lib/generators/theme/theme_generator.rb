class ThemeGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|

      # Theme directory
      m.directory "themes/#{file_name}"
      m.directory "themes/#{file_name}/content"
      m.directory "themes/#{file_name}/content/pages"
      m.directory "themes/#{file_name}/content/protected-pages"
      m.directory "themes/#{file_name}/locale"
      m.directory "themes/#{file_name}/views"


      # images
      m.directory "public/images/#{file_name}"

      #stylesheets
      m.directory "public/stylesheets/themes"
      m.directory "public/stylesheets/themes/#{file_name}"
      m.file "stylesheets/styles.css", "public/stylesheets/themes/#{file_name}/styles.css"

      # localization
      m.file "locale/en.yml", "themes/#{file_name}/locale/en.yml"

      m.readme "INSTALL"
    end
  end

end



