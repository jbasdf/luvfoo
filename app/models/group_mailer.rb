class GroupMailer < ActionMailer::Base

    def invite(inviter, group, email, name, subject, message)
        
        @recipients     = email
        @from           = GlobalConfig.email_from
        @sent_on        = Time.now
        @subject        = subject
        @headers        = {}

        # Email body substitutions
        @body[:name] = name
        @body[:message] = message
        @body[:inviter] = inviter
        @body[:group] = group
        
    end

end




