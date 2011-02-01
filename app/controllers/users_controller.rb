class UsersController < ApplicationController
  before_filter :require_admin, :only => [:index]

  def index
    @users = User.all(:order => "email")
  end

  # render new.rhtml
  def new
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
      Mailer.deliver_reset_password(user)
    else
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
    username = params[:id].gsub('_', ' ')
    @user = User.find_by_username(username)
    redirect_to home_path unless params[:secret] == @user.crypted_password
  end

  # PUT /users/1/xyzzy
  # PUT /users/1/xyzzy.xml
  def update
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    username = params[:id].gsub('_', ' ')
    @user = User.find_by_username(username)
    redirect_to(home_url) and return if @user.crypted_password != params[:secret]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User information was successfully updated.'
        format.html { redirect_to login_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "reset_password" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end
