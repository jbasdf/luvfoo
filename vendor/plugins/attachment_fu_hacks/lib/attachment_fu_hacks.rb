Technoweenie::AttachmentFu::InstanceMethods.module_eval do

  # Overriding this method to allow content_type to be detected when
  # swfupload submits images with content_type set to 'application/octet-stream'
  def uploaded_data=(file_data)
    if file_data.respond_to?(:content_type)
      return nil if file_data.size == 0
      self.content_type = detect_mimetype(file_data)
      self.filename     = file_data.original_filename if respond_to?(:filename)
    else
      return nil if file_data.blank? || file_data['size'] == 0
      self.content_type = file_data['content_type']
      self.filename =  file_data['filename']
      file_data = file_data['tempfile']
    end
    if file_data.is_a?(StringIO)
      file_data.rewind
      self.temp_data = file_data.read
    else
      self.temp_path = file_data
    end
  end

  def detect_mimetype(file_data)
    if file_data.content_type.strip == "application/octet-stream"
      return File.mime_type?(file_data.original_filename)
    else
      return file_data.content_type
    end
  end

  protected

  # Downcase and remove extra underscores from uploaded images
  def sanitize_filename(filename)
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''

      # Finally, replace all non alphanumeric, underscore or periods with underscore
      name.gsub! /[^A-Za-z0-9\.\-]/, '_'

      # Remove multiple underscores
      name.gsub!(/\_+/, '_')

      # Downcase result including extension
      name.downcase!
    end
  end
end


Technoweenie::AttachmentFu::Backends::FileSystemBackend.module_eval do
  # Force tests to use a temporary directory instead of the project's public directory
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
    File.join(env_dir, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  # Use this to override the default directory when in test mode
  def env_dir
    RAILS_ENV == "test" ? Dir::tmpdir() : RAILS_ROOT
  end
end


Technoweenie::AttachmentFu::Processors::MiniMagickProcessor.module_eval do

  protected

  # from http://www.dannyhiemstra.nl/article/attachment_fu-and-square-thumbnails-with-mini_magick
  # Performs the actual resizing operation for a thumbnail
  def resize_image(img, size)
    size = size.first if size.is_a?(Array) && size.length == 1
    img.combine_options do |commands|
      commands.strip unless attachment_options[:keep_profile]
      if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
        if size.is_a?(Fixnum)
          size = [size, size]
          commands.resize(size.join('x'))
        else
          commands.resize(size.join('x') + '!')
        end
      elsif size.is_a?(String) and size =~ /e$/
        # extended thumbnail
        size = size.gsub(/e/, '')
        commands.resize(size.to_s + '>')
        commands.background('#ffffff')
        commands.gravity('center')
        commands.extent(size)
      elsif size.is_a?(String) and size =~ /c$/
        # generate cropped thumbnail
        size = size.gsub(/c/, '')

        # resize the image first before passing the crop command
        img.resize("#{size.to_s}^")

        commands.gravity('Center')
        commands.crop(size)
      else
        commands.resize(size.to_s)
      end
    end
    self.temp_path = img
  end

end
