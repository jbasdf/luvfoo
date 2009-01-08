Test::Unit::TestCase.class_eval do

  def self.should_require_login(*actions)
    actions.each do |action|
      should "Require login for '#{action}' action" do
        get(action)
        assert_redirected_to(login_url)
      end
    end
  end

  #from: http://blog.internautdesign.com/2008/9/11/more-on-custom-shoulda-macros-scoping-of-instance-variables
  def self.should_not_allow action, object, url= "/login", msg=nil
    msg ||= "a #{object.class.to_s.downcase}" 
    should "not be able to #{action} #{msg}" do
      object = eval(object, self.send(:binding), __FILE__, __LINE__)
      get action, :id => object.id
      assert_redirected_to url
    end
  end

  def self.should_allow action, object, msg=nil
    msg ||= "a #{object.class.to_s.downcase}" 
    should "be able to #{action} #{msg}" do
      object = eval(object, self.send(:binding), __FILE__, __LINE__)
      get action, :id => object.id
      assert_response :success
    end
  end

end
