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
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up! To help you get started, have a look at the 'frequently-asked-questions' page: click where it says 'FAQ' at the top."
    else
      render :action => 'new'
    end
  end

  def send_password_reset
    if params[:login].blank?
      flash[:warning] = "Oops: Fill in your login name, <i>then</i> click the 'click here' link below."
      redirect_to login_path and return
    end

    user = User.find_by_login(params[:login])
    if user
      Mailer.deliver_reset_password(user)
    else
      Mailer.deliver_admin_message("Password reset, user not found",
        "Someone asked to reset their password using the login\n" +
        "'#{params[:login]}', but no user with this login was found.")
    end
    if current_user.try(:admin)
      flash[:notice] = "Password-reset link sent to #{user.email}"
      redirect_to users_path
    else
      flash[:notice] = "We've sent a password-reset link to your registered email address."
      redirect_to login_path
    end
  end
  
  def reset_password
    login = params[:id].gsub('_', ' ')
    @user = User.find_by_login(login)
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
    login = params[:id].gsub('_', ' ')
    @user = User.find_by_login(login)
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
