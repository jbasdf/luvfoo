module JsonMethods

  protected 
  
  def basic_uploads_json(obj)
    obj.to_json(:only => [:id, :filename], :methods => [:icon, :public_filename])
  end
  
end
