module ThemeHelper

  def theme_stylesheet_link_tag
    stylesheet_link_tag "themes/#{current_theme}"
  end

end
