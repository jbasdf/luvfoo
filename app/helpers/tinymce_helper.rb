module TinymceHelper
  
  # Pass paths into the image dialog via hidden fields
  def mce_fields(load_images_path, load_files_path, pages_path, parent_type, parent_id)
    '<input id="image-path" type="hidden" value="' + load_images_path + '">' + 
    '<input id="file-path" type="hidden" value="' + load_files_path + '">' + 
    '<input id="pages-path" type="hidden" value="' + pages_path + '">' + 
    '<input id="parent-type" type="hidden" value="' + parent_type + '">' + 
    '<input id="parent-id" type="hidden" value="' + parent_id.to_s + '">' + 
    '<input id="session-key" type="hidden" value="' + GlobalConfig.session_key + '">' + 
    '<input id="session-id" type="hidden" value="' + session.session_id + '">'
  end
  
end