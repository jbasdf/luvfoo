class MessagesController < ApplicationController
  
  before_filter :login_required
  before_filter :can_send, :only => :create
  before_filter :setup
  
  def index
    @message = Message.new
    if current_user.received_messages.empty? && current_user.has_network?
      flash[:notice] = _('You have no mail in your inbox.  Send a message to someone.')
      #redirect_to new_user_message_path(current_user) and return
    end
  end
  
  def destroy
    @message ||= current_user.received_messages.find params[:id] rescue nil
    @message.destroy
    flash[:notice] = _('Message deleted')
    redirect_to user_messages_path(@user)
  end
  
  def create
    @message = current_user.sent_messages.create(params[:message]) 
    respond_to do |format|
      if @message.new_record?
        format.js do
          render :update do |page|
            page.alert @message.errors.to_s
          end
        end
      else
        
        format.js do
          render :update do |page|
            
            # special kind of message (decline a membership request)
            if params[:membership_request_id]
              MessagesController.decline_membership(page, params[:membership_request_id], current_user)
            else
              msg = _("Message sent.")
            end
        
            page.alert msg if msg
            page << "jQuery('#message_subject, #message_body').val('');"
            page << "tb_remove();"
          end
        end
      end
    end
  end
  
  def new
    @message = Message.new
    respond_to do |format|
      format.html
    end
  end
  
  def sent
    @message = Message.new
  end
  
  def show
    #@message = current_user.sent_messages.find params[:id] rescue nil
    @message ||= current_user.received_messages.find params[:id] rescue nil
    @message.mark_read
    @to_list = [@message.sender]
    respond_to do |format|
      format.html
    end
  end
  
  def self.decline_membership page, membership_request_id, decliner
    mr = MembershipRequest.find(membership_request_id)
    if mr == nil
      page.alert _('(unable to decline)')
    else
      if mr.decline(decliner)
        page.alert _("Their membership request was declined and your message was sent.")
        page << "jQuery('#group_pledge_#{membership_request_id}').html('(declined!)');"
      else
        page.alert _('(unable to decline)')
      end
    end
  end
  
  private
  
  def can_send
    render :update do |page|
      page.alert _("Sorry, you can't send messages.")
    end unless current_user.can_send_messages
  end
  
  def setup
    @user = User.find_by_login(params[:user_id]) || current_user
  end
  
end
