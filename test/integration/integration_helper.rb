module IntegrationHelper

  module UserHelper

    def goes_to(path, template)
      get path
      if template
        assert_template template, @response.body
      end
      assert_response :success
    end

    def goes_to_login
      get "/login"
      assert_response :success
      assert_template "sessions/new"
    end

    # We assume that all passwords are 'test'.  That is the value currently set in users.yml
    def logs_in_as(user)
      @user = users(user)
      post "/session", :login => @user.login, :password => 'test'
      should_set_the_flash_to(/Logged in successfully/i)  
      is_redirected_to "users/show"
    end

    def is_redirected_to(template)
      assert_response :redirect
      follow_redirect!
      assert_response :success
      assert_template(template)
    end

    def should_set_the_flash_to(val)
      assert_contains flash.values, val, ", Flash: #{flash.inspect}"
    end

    def logs_out
      get "/logout"
      is_redirected_to("sessions/new")
    end

  end

  def new_session_as(user)
    @user = user
    new_session do |sess|
      sess.goes_to_login
      sess.logs_in_as(user)
      yield sess if block_given?
    end
  end

end
