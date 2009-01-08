class Groups::InvitesController < ApplicationController

  include GroupMethods
  
  before_filter :get_group
  before_filter :setup
  before_filter :membership_required

  def new
    render
  end

  def create
    sent_emails = false

    params[:email].each_with_index do |email, i|
      name = params[:name][i]
      GroupMailer.deliver_invite(current_user, @group, email, name, params[:subject], params[:message_body])
      sent_emails = true
    end

    respond_to do |format|
      if sent_emails
        format.html do
          flash[:notice] = _("Thank you for inviting your friends to join '%{group_name}' on %{site}" % {:group_name => @group.name, :site => GlobalConfig.application_name})
          redirect_to group_path(@group)
        end
      else
        format.html do
          flash.now[:error] = _("Please specify an email address of a friend you would like to invite to join '%{group_name}'" % {:group_name => @group.name})
          render :action => :new
        end
      end
    end

  end

  private

  def setup
    @user = current_user
    @subject = params[:subject] || _("Please come and join me on %{group_name}" % {:group_name => @group.name})
    @message_body = params[:message_body] || _("Please come and join our group '%{group_name}' on %{site}." % {:group_name => @group.name, :site => GlobalConfig.application_name})
  end

end
