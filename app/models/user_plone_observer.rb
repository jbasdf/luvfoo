class UserPloneObserver < ActiveRecord::Observer

    observe User
    
    def before_save(user)
        return if user.nil?
        return if user.password.nil?
        return if user.password.empty?
        if GlobalConfig.integrate_plone
            user.tmp_password = user.password
            user.plone_password = Digest::SHA1.hexdigest("#{user.password}")
        end
    end

    def after_create(user)    
        #PloneWorker.asynch_process_plone_users(:user_id => user.id, :password => user.password) if GlobalConfig.integrate_plone
    end
    
end