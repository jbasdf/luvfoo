class Admin::BaseController < ApplicationController

    before_filter :login_required 
    
    layout('admin')
    
    protected
    
    def get_user
      @user = current_user
    end
        
    def authorized?
        is_admin?
    end

    def permission_denied      
        respond_to do |format|
            format.html do
                redirect_to home_path
            end
        end
    end
    
end