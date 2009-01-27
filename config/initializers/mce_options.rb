content_css = ['/stylesheets/reset.css', '/stylesheets/ie.css', '/stylesheets/application.css', '/stylesheets/common.css', '/stylesheets/standard.css']
if Rails.env.production?
  content_css = ['/stylesheets/all.css']
end
GlobalConfig.advanced_mce_options = {
  :theme => 'advanced',
  :content_css => content_css,
  :body_id => 'content',
  :mode => "textareas",
  :height => 650,
  :width => 830,
  :browsers => %w{msie gecko safari},
  :theme_advanced_layout_manager => "SimpleLayout",
  :theme_advanced_statusbar_location => "bottom",
  :theme_advanced_toolbar_location => "top",
  :theme_advanced_toolbar_align => "left",
  :theme_advanced_resizing => true,
  :relative_urls => false,
  :convert_urls => false,
  :cleanup => true,
  :cleanup_on_startup => true,  
  :convert_fonts_to_spans => true,
  :theme_advanced_resize_horizontal => false,
  :theme_advanced_buttons1 => %w{save cancel print preview separator
                                search replace separator
                                cut copy paste pastetext pasteword selectall undo redo separator
                                bold italic underline strikethrough styleprops separator 
                                justifyleft justifycenter justifyright indent outdent separator 
                                bullist numlist separator 
                                link unlink image file media anchor separator                                 
                                help},
  :theme_advanced_buttons2 => %w{formatselect fontselect fontsizeselect forecolor backcolor separator
                                 tablecontrols separator
                                 sub sup charmap separator
                                 template visualaid fullscreen code},
  :theme_advanced_buttons3 => [],
  :plugins => %w{ paste media preview inlinepopups safari save searchreplace table style template fullscreen print autosave advimagetoo advlinktoo advfiletoo},
  :editor_deselector => "mceNoEditor",
  :editor_selector => 'mceEditor',
  :remove_script_host => true,
  :extended_valid_elements => "img[class|src|flashvars|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name|obj|param|embed|scale|wmode|salign|style],embed[src|quality|scale|salign|wmode|bgcolor|width|height|name|align|type|pluginspage|flashvars],object[align<bottom?left?middle?right?top|archive|border|class|classid|codebase|codetype|data|declare|dir<ltr?rtl|height|hspace|id|lang|name|style|tabindex|title|type|usemap|vspace|width]",
  :template_cdate_classes => "cdate creationdate",
  :template_mdate_classes => "mdate modifieddate",
  :template_selected_content_classes => "selcontent",
  :template_cdate_format => "%m/%d/%Y : %H:%M:%S",
  :template_mdate_format => "%m/%d/%Y : %H:%M:%S"
  }
   
GlobalConfig.simple_mce_options = {
  :theme => 'advanced',
  :content_css => content_css,
  :body_id => 'content',
  :browsers => %w{msie gecko safari},
  :cleanup_on_startup => true,
  :convert_fonts_to_spans => true,
  :theme_advanced_resizing => true, 
  :theme_advanced_toolbar_location => "top",  
  :theme_advanced_statusbar_location => "bottom", 
  :editor_deselector => "mceNoEditor",
  :theme_advanced_resize_horizontal => false,  
  :theme_advanced_buttons1 => %w{bold italic underline separator bullist numlist separator link unlink},
  :theme_advanced_buttons2 => [],
  :theme_advanced_buttons3 => [],
  :plugins => %w{inlinepopups safari}
  }

GlobalConfig.news_mce_options = GlobalConfig.simple_mce_options.merge({
  :height => 500,
  :width => 830,
  :plugins => %w{ paste media preview inlinepopups safari save searchreplace table style template fullscreen print autosave advimagetoo advlinktoo advfiletoo},
  :theme_advanced_buttons1 => %w{
    formatselect fontselect fontsizeselect forecolor backcolor separator
    bold italic underline separator 
    justifyleft justifycenter justifyright indent outdent separator
    bullist numlist separator 
    link unlink separator
    image file separator
    code},
})
  
GlobalConfig.raw_mce_options = 'template_templates : [
      {
        title : "Team Member Biography",
        src : "/javascripts/tiny_mce/templates/bio.htm",
        description : "Easily add a new biography for a team member."
      },
      {
        title : "Country Page",
        src : "/javascripts/tiny_mce/templates/country.htm",
        description : "Add a new country page."
      }
    ]'
    