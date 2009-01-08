class PloneWorker < Workling::Base

    def process_plone_users(options = {})

        user = User.find(options[:user_id])
        if user
            if !Plone.user_to_plone(user, options[:password])
                PloneWorker.asynch_process_plone_users(:user_id => user.id, :password => options[:password])
            end
        end
        
    end
    
end

