class UsersController < ApplicationController
  before_filter :require_admin, :only => [:index]

  def index
    @users = User.all(:order => "email")
  end

  # render new.rhtml
  def new
    Journal.signup_page_viewed
    @user = User.new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      Journal.user_signed_up(@user)
      self.current_user = @user
      Mailer.deliver_new_user(@user)
      flash[:notice] = "Thanks for signing up! To help you get started, have a look at the 'frequently-asked-questions' page: click where it says 'FAQ' at the top."
      redirect_back_or_default('/')
    else
      render :action => 'new'
    end
  end

  def forgot_password
  end

  def send_password_reset
    if params[:email].blank?
      flash.now[:warning] = "Oops: You didn't enter your email address!"
      render(:action => :forgot_password) and return
    end

    user = User.find_by_email(params[:email])
    if user
      Journal.known_user_got_password_reset_email(user)
      Mailer.deliver_reset_password(user)
    else
      Journal.unknown_user_forgot_password(params[:email])
      Mailer.deliver_admin_message("Password reset, user not found",
        "Someone asked to reset their password using \n" +
        "'#{params[:email]}', but no user with this username or email " +
        "was found.")
    end
    if current_user.try(:admin)
      flash[:notice] = "Password-reset link sent to #{user.email}"
      redirect_to users_path
    else
      flash[:notice] = user \
        ? "We've sent password-reset instructions; " +
          "check your email in a few minutes." \
        : "Thanks - we'll be in touch within 24 hours to help you " +
          "get reconnected. Sorry for the inconvenience!"
      redirect_to login_path
    end
  end
  
  def reset_password
    @user = User.find_by_id(params[:number])
    unless @user
      Journal.bad_reset_password_user(params[:number])
      redirect_to(home_path) and return
    end
    unless params[:secret] == @user.crypted_password
      Journal.bad_reset_password_secret(@user)
      redirect_to(home_path) and return
    end
    Journal.good_reset_password_request(@user)
  end

  # PUT /users/1/xyzzy
  # PUT /users/1/xyzzy.xml
  def update
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    username = User.from_param(params[:id])
    @user = User.find_by_username(username)
    unless @user
      Journal.bad_user_update_user(username)
      redirect_to(home_path) and return
    end
    unless params[:secret] == @user.crypted_password
      Journal.bad_user_update_secret(@user)
      redirect_to(home_path) and return
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        Journal.password_changed(@user)
        flash[:notice] = 'User information was successfully updated.'
        format.html { redirect_to login_url }
        format.xml  { head :ok }
      else
        Journal.password_change_failed(@user)
        format.html { render :action => "reset_password" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end
