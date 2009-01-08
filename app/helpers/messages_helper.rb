module MessagesHelper
    
    def my_friends
        if logged_in?
            (current_user.followers + current_user.friends + current_user.followings)
        else
            []
        end        
    end
    
end
