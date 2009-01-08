class Users::InvitesController < ApplicationController

  include UserMethods
  
  before_filter :login_required
  before_filter :get_user, :setup

  def new
    render
  end

  def create
    sent_emails = false

    params[:email].each_with_index do |email, i|
      name = params[:name][i]
      UserMailer.deliver_invite(current_user, email, name, params[:subject], params[:message_body])
      sent_emails = true
    end

    respond_to do |format|
      if sent_emails
        format.html do
          flash[:notice] = _("Thank you for inviting your friends to join %{site}" % {:site => GlobalConfig.application_name})
          redirect_to user_path(current_user)
        end
      else
        format.html do
          flash.now[:error] = _("Please specify an email address of a friend you would like to invite")
          render :action => :new
        end
      end
    end

  end

  private

  def setup
    @subject = params[:subject] || _("Please come and join me on %{site}") % {:site => _(GlobalConfig.application_name)}
    @message_body = params[:message_body] || _("Please come and join %{site}.") % {:site => _(GlobalConfig.application_name)}
  end

end
