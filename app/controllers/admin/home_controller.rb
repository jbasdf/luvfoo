class Admin::HomeController < Admin::BaseController

  def index
    @user_count = User.count
    @user_inactive_count = User.inactive_count
    
    respond_to do |format|
      format.html {render}
    end
  end
  
end