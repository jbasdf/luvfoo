module JsonMethods

  protected 
  
  def basic_uploads_json(obj)
    obj.to_json(:only => [:id, :data_file_name], :methods => [:icon])
  end
  
end
