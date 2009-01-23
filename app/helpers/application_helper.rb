module ApplicationHelper
  require 'digest/sha1'
  require 'net/http'
  require 'uri'

  def global_site
    @site ||= Site.first
  end

  def get_locale
    locale.to_s
  end
  
  def icon object, size = :small, img_opts = {}
    return "" if object.nil?

    options = {:size => size, :file_column_version => size }

    if object.is_a?(User)
      img_opts = {:title => object.full_name, :alt => object.full_name, :class => size}.merge(img_opts)
      link_to(avatar_tag(object, {:size => size, :file_column_version => size }, img_opts), profile_path(object), { :title => object.full_name })
    elsif object.is_a?(Group)                     
      url = icon_url(object, options)
      return '' if url.nil? || url.empty?
      html_options = {:title => object.name, :alt => object.name, :class => size}.merge(img_opts)
      link_to(image_tag(url, html_options), group_path(object), :title => object.name )
    elsif object.is_a?(NewsItem)                     
      url = icon_url(object, options)
      return '' if url.nil? || url.empty?
      html_options = {:title => object.title, :alt => object.title, :class => size}.merge(img_opts)
      link_to(image_tag(url, html_options), member_story_path(object), { :title => object.title })
    end

  end     

  def default_image(object, size)
    return object.class.to_s.downcase + 's_default_' + size.to_s + '.gif' 
  end

  def icon_url(object, options)
    field = options.delete(:file_column_field) || 'icon'
    return default_image(object, options[:size]) if field.nil? || object.send(field).nil?
    options = options[:file_column_version] || options
    url_for_image_column(object, 'icon', options)
  end

  def icon_tag(object, size, css_class = '')
    css = 'class="' + css_class + '"' if css_class
    '<img src="' + icon_url(object, {:size => size, :file_column_version => size }) + '" ' + css + ' />'
  rescue
    # icon_url can return nil.  If it does return an empty string
    ''
  end

  def icon object, size = :small, img_opts = {}
    return "" if object.nil?

    options = {:size => size, :file_column_version => size }

    if object.is_a?(User)
      img_opts = {:title => object.full_name, :alt => object.full_name, :class => size}.merge(img_opts)
      link_to(avatar_tag(object, {:size => size, :file_column_version => size }, img_opts), profile_path(object), { :title => object.full_name })
    elsif object.is_a?(Group)                     
      url = icon_url(object, options)
      return '' if url.nil? || url.empty?
      html_options = {:title => object.name, :alt => object.name, :class => size}.merge(img_opts)
      link_to(image_tag(url, html_options), group_path(object), :title => object.name )
    elsif object.is_a?(NewsItem)                     
      url = icon_url(object, options)
      return '' if url.nil? || url.empty?
      html_options = {:title => object.title, :alt => object.title, :class => size}.merge(img_opts)
      link_to(image_tag(url, html_options), member_story_path(object), { :title => object.title })
    end

  end     

  def default_image(object, size)
    return object.class.to_s.downcase + 's_default_' + size.to_s + '.gif' 
  end

  def icon_url(object, options)
    field = options.delete(:file_column_field) || 'icon'
    return default_image(object, options[:size]) if field.nil? || object.send(field).nil?
    options = options[:file_column_version] || options
    url_for_image_column(object, 'icon', options)
  end

  def icon_tag(object, size, css_class = '')
    css = 'class="' + css_class + '"' if css_class
    '<img src="' + icon_url(object, {:size => size, :file_column_version => size }) + '" ' + css + ' />'
  rescue
    # icon_url can return nil.  If it does return an empty string
    ''
  end

  def icon_for(upload, size = :icon)
    return '' if upload.nil?
    if upload.is_pdf?
      link_to image_tag('file_icons/pdf.gif', :height => '25'), upload.public_filename
    elsif upload.is_word?
      link_to image_tag('file_icons/word.png', :height => '25'), upload.public_filename  
    elsif upload.is_image?
      link_to image_tag(upload.public_filename(size)), upload.public_filename
    elsif upload.is_mp3?
      link_to image_tag('file_icons/mp3.png', :height => '30'), upload.public_filename
    elsif upload.is_excel?
      link_to image_tag('file_icons/excel.png', :height => '25'), upload.public_filename
    elsif upload.is_text?
      link_to image_tag('file_icons/text.png', :height => '25'), upload.public_filename
    else
      link_to image_tag('blurp_file.png', :height => '25'), upload.public_filename
    end
  rescue => ex
    link_to image_tag('blurp_file.png', :height => '25'), upload.public_filename
  end

  def link_for_shared_uploadable(shared_uploadable)

    case shared_uploadable.class.name
    when 'User'
      link_to(h(shared_uploadable.full_name), profile_path(shared_uploadable))
    when 'Group'
      link_to(h(shared_uploadable.name), group_path(shared_uploadable))
    end

  end

  def custom_form_for(record_or_name_or_array, *args, &proc) 
    options = args.detect { |argument| argument.is_a?(Hash) } 
    if options.nil? 
      options = {:builder => CustomFormBuilder} 
      args << options 
    end 
    options[:builder] = CustomFormBuilder unless options.nil? 
    form_for(record_or_name_or_array, *args, &proc) 
  end

  def custom_remote_form_for(record_or_name_or_array, *args, &proc) 
    options = args.detect { |argument| argument.is_a?(Hash) } 
    if options.nil? 
      options = {:builder => CustomFormBuilder} 
      args << options 
    end 
    options[:builder] = CustomFormBuilder unless options.nil? 
    remote_form_for(record_or_name_or_array, *args, &proc) 
  end

  def less_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    form_for name, *args, &block
  end

  def less_remote_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    remote_form_for name, *args, &block
  end

  def display_standard_flashes(message = 'There were some problems with your submission:')
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
    elsif flash[:error]
      level = 'error'
      if flash[:error].instance_of?( ActiveRecord::Errors) || flash[:error].is_a?( Hash)
        flash_to_display = message
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = flash[:error]
      end
    else
      return
    end
    content_tag 'div', flash_to_display, :class => "flash#{level}"
  end

  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end

  def custom_form_for(record_or_name_or_array, *args, &proc) 
    options = args.detect { |argument| argument.is_a?(Hash) } 
    if options.nil? 
      options = {:builder => CustomFormBuilder} 
      args << options 
    end 
    options[:builder] = CustomFormBuilder unless options.nil? 
    form_for(record_or_name_or_array, *args, &proc) 
  end

  def inline_tb_link link_text, inlineId, html = {}, tb = {}
    html_opts = {
      :title => '',
      :class => 'thickbox'
      }.merge!(html)

    tb_opts = {
      :height => 300,
      :width => 400,
      :inlineId => inlineId
      }.merge!(tb)

    path = '#TB_inline'.add_param(tb_opts)
    link_to(link_text, path, html_opts)
  end

  def tb_video_link youtube_unique_path
    return if youtube_unique_path.blank?
    youtube_unique_id = youtube_unique_path.split(/\/|\?v\=/).last.split(/\&/).first
    p youtube_unique_id
    client = YouTubeG::Client.new
    video = client.video_by GlobalConfig.youtube_base_url+youtube_unique_id rescue return "(video not found)"
    id = Digest::SHA1.hexdigest("--#{Time.now}--#{video.title}--")
    inline_tb_link(video.title, h(id), {}, {:height => 355, :width => 430}) + %(<div id="#{h id}" style="display:none;">#{video.embed_html}</div>)
  end

  def you_tube_video video_unique_path
    return if video_unique_path.blank?
    if video_unique_path.match(/youtube\.com/) != nil
      video_id = video_unique_path.split(/\/|\?v\=/).last.split(/\&/).first
      client = YouTubeG::Client.new
      video = client.video_by GlobalConfig.youtube_base_url+video_id rescue return "(video not found)"
      id = Digest::SHA1.hexdigest("--#{Time.now}--#{video.title}--")
      %(<div id="#{h(id)}">#{video.embed_html}</div>)
    else
      video_id = video_unique_path.split(/videoplay\?docid=/).last.split(/\&/).first
      %(<div>#{google_video_embed_html(video_id)}</div>)
    end
  end

  def google_video_embed_html(video_id)
    '<embed id="VideoPlayback" src="http://video.google.com/googleplayer.swf?docid=' + video_id + '&hl=en&fs=true" style="width:400px;height:326px" allowFullScreen="true" allowScriptAccess="always" type="application/x-shockwave-flash"> </embed>'
  end

  def body_content blog
    youtube_videos = blog.body.scan(/\[youtube:+.+\]|\[googlevideo:+.+\]/)
    body = blog.body.dup.gsub(/\[youtube:+.+\]|\[googlevideo:+.+\]/, '')
    out = sanitize(body)
    #out = sanitize(textilize(body)) TODO textilize messes up the html from the WYSIWYG.  Figure out how to specify whether or not to use it.
    unless youtube_videos.empty?
      out << <<-EOB
      <strong>#{pluralize youtube_videos.size, 'video'}:</strong><br/>
      EOB
      youtube_videos.each do |o|
        out << you_tube_video(o.gsub!(/\[youtube\:|\]|\[googlevideo\:/, ''))
      end
    end
    out
  end

  # only use this on content that has already been sanitized or whitelisted.
  def process_body_content(item)
    youtube_videos = item.body.scan(/\[youtube:+.+\]|\[googlevideo:+.+\]/)
    out = item.body.dup.gsub(/\[youtube:+.+\]|\[googlevideo:+.+\]/, '')
    unless youtube_videos.empty?
      out << <<-EOB
      <strong>#{pluralize youtube_videos.size, 'video'}:</strong><br/>
      EOB
      youtube_videos.each do |o|
        out << you_tube_video(o.gsub!(/\[youtube\:|\]|\[googlevideo\:/, ''))
      end
    end
    out
  end
  
  def truncate(text,len = 30)
    return text if text.size <= len
    text[0, text.rindex(' ', len)] + '...'
  end

  def summarize(content, length = 100)
    return '' if content.nil?
    truncate(sanitize(strip_tags(content.dup.gsub(/\[youtube:+.+\]/, ''))), length)
  end

  def html_summarize(content, length = 100)
    truncate(sanitize(content.dup.gsub(/\[youtube:+.+\]/, '')), length)
  end

  def is_controller?(controller, &block)
    if params[:controller] == controller
      content = capture(&block)
      concat(content, block.binding)
    end
  end

end
