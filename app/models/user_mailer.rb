class UserMailer < ActionMailer::Base

    def signup_notification(user)
        setup_email(user)

        # Email header info
        @subject = _("Activate your %{application_name} account!") % {:application_name => _(GlobalConfig.application_name)}

        # Email body substitutions
        @body[:login] = "#{user.login}"
        @body[:url]  = "http://#{GlobalConfig.application_url}/activate/#{user.activation_code}"

        #render :file => "user_mailer/signup_notification"
    end

    def reset_notification(user)
        setup_email(user)

        # Email header info
        @subject = _("Your %{application_name} account has not yet been activated") % {:application_name => _(GlobalConfig.application_name)}

        # Email body substitutions
        @body[:login] = "#{user.login}"
        @body[:reset_url]  = "http://#{GlobalConfig.application_url}/reset_password"
        @body[:activate_url]  = "http://#{GlobalConfig.application_url}/activate/#{user.activation_code}"
    end
    
    def activation(user)
        setup_email(user)
        @subject    = _("Your %{application_name} account has been activated!") % {:application_name => _(GlobalConfig.application_name)}
        @body[:url]  = "http://#{GlobalConfig.application_url}/"
    end

    def forgot_password(user)
        setup_email(user)
        @subject    = _("You have requested to change your %{application_name} password") % {:application_name => _(GlobalConfig.application_name)}
        @body[:url]  = "http://#{GlobalConfig.application_url}/reset_password/#{user.password_reset_code}"
    end

    def reset_password(user)
        setup_email(user)
        @subject    = _("Your %{application_name} password has been reset.") % {:application_name => _(GlobalConfig.application_name)}
    end

    def follow inviter, invited, description
        @subject        = _("Making connections through %{application_name}") % {:application_name => _(GlobalConfig.application_name)}
        @recipients     = invited.email
        @body['inviter']   = inviter
        @body['invited']   = invited
        @body['description'] = description
        @from           = GlobalConfig.email_from
        @sent_on        = Time.new
        @headers        = {}
    end

    def invite(inviter, email, name, subject, message)
        
        @recipients     = email
        @from           = GlobalConfig.email_from
        @sent_on        = Time.now
        @subject        = subject
        @headers        = {}

        # Email body substitutions
        @body[:name] = name
        @body[:message] = message
        @body[:inviter] = inviter
    end
    
    protected
    def setup_email(user)
        @recipients  = "#{user.email}"
        @from        = "#{GlobalConfig.email_from}"
        @sent_on     = Time.now
        @body[:user] = user
    end
end




