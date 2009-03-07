module ThemeHelper

  def theme_stylesheet_link_tag(*sources)
    options = sources.extract_options!.stringify_keys
    sheets = sources.collect {|style| "themes/#{current_theme}/#{style}"} || "themes/#{current_theme}/styles"
    stylesheet_link_tag sheets, options
  end

end