class Users::EntryController < ApplicationController

  before_filter :login_required, :only => [:new]

  def new
    render
  end
  def show
    @user = User.find_by_login(params[:user_id])
    @entry = Entry.find(params[:id])
    render
  end

end
