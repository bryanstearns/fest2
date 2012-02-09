# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem

  # render new.rhtml
  def new
    Journal.login_page_viewed
  end

  def act_as
    raise(ActiveRecord::NotFound) unless Rails.env.development?
    raise(ActiveRecord::NotFound) unless current_user_is_admin?
    username = User.from_param(params[:user_id])
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    self.current_user = User.find_by_username!(username)
    Journal.admin_acted_as
    flash[:warning] = "You're now acting as #{current_user.username} / #{current_user.email}"
    redirect_back_or_default('/')
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      Journal.user_logged_in
      redirect_back_or_default('/')
      # flash[:notice] = "Logged in successfully"
    else
      flash.now[:warning] = "Oops, that's not a recognized email address and password."
      Journal.user_login_failed(params[:email])
      @attempt_failed = true
      render :action => 'new'
    end
  end

  def destroy
    Journal.user_logged_out
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    # flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
