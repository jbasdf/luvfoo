class UserObserver < ActiveRecord::Observer

  def after_create(user)
    if !GlobalConfig.automatically_activate
      UserMailer.deliver_signup_notification(user)
    end
  end

  def after_save(user)
    if !GlobalConfig.automatically_activate  && GlobalConfig.send_activated_email
      #UserMailer.deliver_activation(user) if user.recently_activated? 
      UserMailer.deliver_activation(user) if user.pending?
    end

    if user.recently_forgot_password? && !user.active?
      UserMailer.deliver_reset_notification(user) # user never activated their account.  let them know so they can then reset their password.
    else
      UserMailer.deliver_forgot_password(user) if user.recently_forgot_password?
      UserMailer.deliver_reset_password(user) if user.recently_reset_password?
    end        

  end

end