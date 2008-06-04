class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem
  

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
      Mailer.deliver_new_user(@user, _)
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up! To help you get started, have a look at the 'frequently-asked-questions' page: click where it says 'FAQ' at the top."
    else
      render :action => 'new'
    end
  end

  def send_password_reset
    user = User.find_by_login(params[:login])
    Mailer.deliver_reset_password(user, _) if user
    flash[:notice] = "We've sent a password-reset link to your registered email address."
    redirect_to login_path
  end
  
  def reset_password
    @user = User.find(params[:id])
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
    @user = User.find(params[:id])
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
